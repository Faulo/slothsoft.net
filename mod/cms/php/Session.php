<?php
/***********************************************************************
 * \CMS\Session v1.00 16.12.2012 © Daniel Schulz
 * 
 * 	Changelog:
 *		v1.00 16.12.2012
 *			initial release
 ***********************************************************************/
namespace Slothsoft\CMS;

use Slothsoft\DBMS\Manager;
use Exception;

class Session
{

    const GLOBAL_SESSION = null;

    protected $dbName = 'cms';

    protected $tableName = 'session';

    protected $cookieName = 'session-key';

    protected $dbmsTable;

    protected $key;

    protected $data;

    protected $initialized;

    public function __construct()
    {
        $this->initialized = false;
    }

    protected function install()
    {
        $sqlCols = [
            'id' => 'int NOT NULL AUTO_INCREMENT',
            'session' => 'CHAR(40) CHARACTER SET ascii COLLATE ascii_bin NULL',
            'name' => 'CHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL',
            'data' => 'longtext NOT NULL',
            'create-time' => 'int NOT NULL DEFAULT "0"',
            'modify-time' => 'int NOT NULL DEFAULT "0"',
            'access-time' => 'int NOT NULL DEFAULT "0"'
        ];
        $sqlKeys = [
            'id',
            'session',
            'name',
            [
                'type' => 'UNIQUE KEY',
                'columns' => [
                    'session',
                    'name'
                ],
                'name' => 'session-name'
            ],
            'create-time',
            'modify-time',
            'access-time'
        ];
        $options = [            // 'engine' => 'MyISAM',
        ];
        $this->dbmsTable->createTable($sqlCols, $sqlKeys, $options);
    }

    protected function init()
    {
        if (! $this->initialized) {
            $this->initialized = true;
            try {
                $this->initKey($this->getCookie($this->cookieName));
                $this->dbmsTable = Manager::getTable($this->dbName, $this->tableName);
                if (! $this->dbmsTable->tableExists()) {
                    $this->install();
                }
            } catch (Exception $e) {
                $this->dbmsTable = null;
            }
        }
    }

    protected function initKey($key = null)
    {
        if ($key === null) {
            $key = $this->generateKey();
        }
        $this->data = [];
        $this->key = $key;
        $this->setCookie($this->cookieName, $this->key);
    }

    public function getGlobalValue($key, $val = null)
    {
        $this->init();
        return $this->loadData(self::GLOBAL_SESSION, $key, $val);
    }

    public function setGlobalValue($key, $val = null)
    {
        $this->init();
        $this->saveData(self::GLOBAL_SESSION, $key, $val);
    }

    public function getDataValue($key, $val = null)
    {
        $this->init();
        $this->data[$key] = $this->loadData($this->key, $key, $val);
        return $this->data[$key];
    }

    public function setDataValue($key, $val = null)
    {
        $this->init();
        $this->data[$key] = $val;
        $this->saveData($this->key, $key, $val);
    }

    public function setCookie($key, $val = null)
    {
        if (! headers_sent()) {
            setcookie($key, $val, time() + TIME_MONTH, '/');
        }
        $_COOKIE[$key] = $val;
    }

    public function getCookie($key, $val = null)
    {
        return isset($_COOKIE[$key]) ? $_COOKIE[$key] : $val;
    }

    protected function loadData($session, $key, $val)
    {
        $arr = [];
        $arr['session'] = $session;
        $arr['name'] = $this->hash($key);
        $res = $this->dbmsTable ? $this->dbmsTable->select('data', $arr) : null;
        return $res ? $this->decodeData(current($res), true) : $val;
    }

    protected function saveData($session, $key, $val)
    {
        $arr = [];
        $arr['session'] = $session;
        $arr['name'] = $this->hash($key);
        
        if ($this->dbmsTable) {
            if ($idList = $this->dbmsTable->select('id', $arr)) {
                try {
                    $this->dbmsTable->update([
                        'data' => $this->encodeData($val)
                    ], $idList);
                } catch (Exception $e) {}
            } else {
                $arr['data'] = $this->encodeData($val);
                try {
                    $this->dbmsTable->insert($arr);
                } catch (Exception $e) {}
            }
        }
    }

    protected function generateKey()
    {
        if (isset($_SERVER, $_SERVER['REQUEST_TIME_FLOAT'], $_SERVER['REMOTE_ADDR'])) {
            $ret = sha1($_SERVER['REQUEST_TIME_FLOAT'] . '-' . $_SERVER['REMOTE_ADDR']);
        } else {
            $ret = sha1(microtime(true));
        }
        return $ret;
    }

    protected static $hashList = [];

    protected function hash($name)
    {
        if (! isset(self::$hashList[$name])) {
            self::$hashList[$name] = sha1($name);
        }
        return self::$hashList[$name];
    }

    protected function encodeData($data)
    {
        return json_encode($data);
    }

    protected function decodeData($data)
    {
        return json_decode($data, true);
    }
}