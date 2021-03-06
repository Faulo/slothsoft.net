<?php
namespace Slothsoft\CMS\Tracking;

use Slothsoft\CMS\HTTPRequest;
use DOMDocument;

class View
{

    protected $archive = null;

    protected $groupList = [];

    protected $searchList = [];

    protected $logURI = null;

    protected $pageNo = null;

    protected $pageLimit = 500;

    public function __construct(Archive $archive)
    {
        $this->archive = $archive;
        
        $config = $this->archive->getConfig();
        foreach ($config['logColumns'] as $key => $column) {
            if ($column['groupable']) {
                $this->groupList[$key] = '';
            }
            if ($column['searchable']) {
                $this->searchList[$key] = '';
            }
        }
    }

    public function parseRequest(HTTPRequest $request)
    {
        $this->pageNo = (int) $request->getInputValue('page', 0);
        $this->logURI = (string) $request->getInputValue('log');
        /*
         * $showBots = $request->getInputValue('bots', null);
         * if ($showBots !== null) {
         * if ((int) $showBots) {
         * $this->groupList['REQUEST_TURING'] = 'bot';
         * } else {
         * $this->groupList['REQUEST_TURING'] = 'human';
         * }
         * }
         * //
         */
        
        $group = (array) $request->getInputValue('group', []);
        foreach ($this->groupList as $key => &$val) {
            if (isset($group[$key])) {
                $val = (string) $group[$key];
            }
        }
        unset($val);
        $search = (array) $request->getInputValue('search', []);
        foreach ($this->searchList as $key => &$val) {
            if (isset($search[$key])) {
                $val = (string) $search[$key];
            }
        }
        unset($val);
    }

    public function asNode(DOMDocument $dataDoc)
    {
        $retFragment = $dataDoc->createDocumentFragment();
        
        $config = $this->archive->getConfig();
        $table = $this->archive->getLogTableByURI($this->logURI);
        
        $groupFilter = [];
        $searchFilter = [];
        $params = [];
        $params['log'] = $this->logURI;
        $params['page'] = $this->pageNo;
        $params['group'] = [];
        $params['search'] = [];
        foreach ($this->groupList as $key => $val) {
            if (strlen($val)) {
                $params['group'][$key] = $val;
                $groupFilter[$key] = $val === 'NULL' ? null : $val;
            }
        }
        foreach ($this->searchList as $key => $val) {
            if (strlen($val)) {
                $params['search'][$key] = $val;
                $searchFilter[] = sprintf('AND `%s` LIKE "%s"', $key, $val);
            }
        }
        $searchFilter = implode(' ', $searchFilter);
        
        $parentNode = $dataDoc->createElement('groupList');
        $tableList = $this->archive->getLogTableList();
        foreach ($tableList as $key => $tmp) {
            $query = $params;
            $query['log'] = $key;
            
            $node = $dataDoc->createElement('group');
            $node->appendChild($dataDoc->createTextNode($key));
            $node->setAttribute('uri', './?' . http_build_query($query));
            if ($tmp === $table) {
                $node->setAttribute('active', 'active');
            }
            $parentNode->appendChild($node);
        }
        $retFragment->appendChild($parentNode);
        
        foreach ($this->groupList as $key => $val) {
            $query = $params;
            unset($query['group'][$key]);
            
            $parentNode = $dataDoc->createElement('groupList');
            $node = $dataDoc->createElement('group');
            $node->appendChild($dataDoc->createTextNode('*'));
            $node->setAttribute('uri', './?' . http_build_query($query));
            if ($val === '') {
                $node->setAttribute('active', 'active');
            }
            $parentNode->appendChild($node);
            
            $rowList = $table->selectGroup($key, $groupFilter, $searchFilter);
            foreach ($rowList as $row) {
                if ($row === null) {
                    $row = 'NULL';
                }
                $query['group'][$key] = $row;
                
                $node = $dataDoc->createElement('group');
                $node->appendChild($dataDoc->createTextNode(implode(' ', preg_split('/[\/\-]/', $row, 2))));
                $node->setAttribute('uri', './?' . http_build_query($query));
                if ($val === $row) {
                    $node->setAttribute('active', 'active');
                }
                $parentNode->appendChild($node);
            }
            $retFragment->appendChild($parentNode);
        }
        
        $parentNode = $dataDoc->createElement('groupList');
        $count = $table->selectCount($groupFilter, $searchFilter);
        $pageCount = (int) ceil($count / $this->pageLimit);
        $query = $params;
        for ($i = 0; $i < $pageCount; $i ++) {
            if ($i < 50 or ($i + 1) === $pageCount) {
                $query['page'] = $i;
                
                $node = $dataDoc->createElement('group');
                $node->appendChild($dataDoc->createTextNode($i + 1));
                $node->setAttribute('uri', './?' . http_build_query($query));
                if ($this->pageNo === $i) {
                    $node->setAttribute('active', 'active');
                }
                $parentNode->appendChild($node);
            }
        }
        $retFragment->appendChild($parentNode);
        
        $rowList = $table->select($groupFilter, $searchFilter, $this->pageNo, $this->pageLimit);
        
        foreach ($config['logColumns'] as $key => $column) {
            if ($column['visible']) {
                $node = $dataDoc->createElement('col');
                $node->appendChild($dataDoc->createTextNode($key));
                $node->setAttribute('form-key', sprintf('search[%s]', $key));
                if (isset($this->searchList[$key])) {
                    $node->setAttribute('form-val', $this->searchList[$key]);
                }
                foreach ($column as $attr => $val) {
                    if ($val) {
                        $node->setAttribute($attr, '');
                    }
                }
                $retFragment->appendChild($node);
            }
        }
        
        foreach ($rowList as $row) {
            $node = $dataDoc->createElement('log');
            foreach ($row as $key => $val) {
                if ($val !== null) {
                    $val = preg_replace('/[\x00-\x08\x0B\x0C\x0E-\x1F\x80-\x9F]/u', '', $val);
                    $node->setAttribute($key, $val);
                }
                /*
                 * //if (isset($arr[$key]) and strlen($arr[$key]) and $arr[$key] !== '') {
                 * //$val = preg_replace('/^GIF89a.+/s', 'GIF89a', $arr[$key]);
                 * $node->setAttribute($key, $val);
                 * //}
                 * //
                 */
            }
            $retFragment->appendChild($node);
        }
        
        return $retFragment;
    }
}