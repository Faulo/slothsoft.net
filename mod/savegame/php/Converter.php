<?php
namespace Slothsoft\Savegame;

use Slothsoft\Savegame\Script\Parser;
declare(ticks = 1000);

class Converter
{

    /**
     * @return \Slothsoft\Savegame\Converter
     */
    public static function getInstance()
    {
        static $instance;
        if (!$instance) {
            $instance = new Converter();
        }
        return $instance;
    }

    public function encodeInteger($val, $size = 1)
    {
        $val = (int) $val;
        $ret = pack('N', $val);
        $ret = substr($ret, - $size);
        return $ret;
    }

    public function encodeSignedInteger($val, $size = 1)
    {
        return $this->encodeInteger($val, $size);
    }

    public function encodeString($val, $size = 1, $encoding = '')
    {
        $val = (string) $val;
        $val = trim($val);
        if ($encoding) {
            $val = mb_convert_encoding($val, $encoding, 'UTF-8');
        }
        $ret = substr($val, 0, $size);
        $ret = str_pad($ret, $size, "\0");
        return $ret;
    }

    public function encodeBinary($val)
    {
        return hex2bin(preg_replace('~\s+~', '', $val));
    }

    public function encodeScript($val)
    {
        $parser = new Parser();
        return $parser->code2binary($val);
    }

    public function decodeInteger($val, $size = 1)
    {
        switch ($size) {
            case 1:
                $format = 'C';
                break;
            case 2:
                $format = 'n';
                break;
            case 3:
                $val = "\0" . $val;
                $format = 'N';
                break;
            case 4:
                $format = 'N';
                break;
            default:
                my_dump('unknown integer size: ' . $size);
                die();
                break;
        }
        return unpack($format, $val)[1];
    }

    public function decodeSignedInteger($val, $size = 1)
    {
        $ret = $this->decodeInteger($val, $size);
        if ($ret > $this->pow256($size) / 2) {
            $ret -= $this->pow256($size);
        }
        return $ret;
    }

    public function decodeString($val, $size = 1, $encoding = '')
    {
        $hex = bin2hex($val);
        $ret = '';
        for ($i = 0, $j = strlen($hex); $i < $j; $i += 2) {
            $c = hexdec($hex[$i] . $hex[$i + 1]);
            if ($c > 31) {
                $ret .= chr($c);
            } else {
				break;
			}
        }
        if ($encoding) {
            $ret = mb_convert_encoding($ret, 'UTF-8', $encoding);
        }
        return $ret;
    }

    public function decodeBinary($val)
    {
        return chunk_split(bin2hex($val), 2, ' ');
    }

    public function decodeScript($val)
    {
        $parser = new Parser();
        return $parser->binary2code($val);
    }
    
    public function pow2($size) {
        static $powList = [];
        if (!isset($powList[$size])) {
            $powList[$size] = pow(2, $size);
        }
        return $powList[$size];
    }
    public function pow256($size) {
        static $powList = [];
        if (!isset($powList[$size])) {
            $powList[$size] = pow(256, $size);
        }
        return $powList[$size];
    }
}