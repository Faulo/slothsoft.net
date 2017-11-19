<?php
namespace Slothsoft\Savegame\Node;

declare(ticks = 1000);

class DictionaryNode extends AbstractNode
{

    protected $optionList;

    public function __construct()
    {
        parent::__construct();
        $this->strucData['dictionary-id'] = '';
    }

    protected function loadNode()
    {
        $this->optionList = [];
        foreach ($this->getStrucElementChildren() as $optionElement) {
            $key = $optionElement->hasAttribute('key') ? $optionElement->getAttribute('key') : (string) count($this->optionList);
            $val = $optionElement->getAttribute('val');
            
            $this->optionList[$key] = $val;
        }
    }

    protected function loadChildren()
    {}

    public function hasOption(string $key)
    {
        return isset($this->optionList[$key]);
    }

    public function getOption(string $key)
    {
        return isset($this->optionList[$key]) ? $this->optionList[$key] : null;
    }

    public function getDictionaryId()
    {
        return $this->strucData['dictionary-id'];
    }

    public function getChildrenXML()
    {
        $ret = '';
        foreach ($this->optionList as $key => $val) {
            $ret .= sprintf('<option key="%s" val="%s"/>', htmlspecialchars($key, ENT_COMPAT | ENT_XML1), htmlspecialchars($val, ENT_COMPAT | ENT_XML1));
        }
        return $ret;
    }
}