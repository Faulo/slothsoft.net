<?php
namespace Slothsoft\CMS;

use Closure;
use InterExec;
declare(ticks = 1000);

class HTTPCommand
{

    protected $exec;

    public function __construct($command)
    {
        $this->exec = new InterExec($command);
    }

    public function getMime()
    {
        return null;
    }

    public function getEncoding()
    {
        return null;
    }

    public function getHeaderList()
    {
        return [];
    }

    public function run()
    {
        $this->exec->run();
    }

    // EventTarget
    public function addEventListener($type, Closure $listener, $capture = false)
    {
        $this->exec->on($type, function (InterExec $exec, $data) use ($type, $listener) {
            $eve = new HTTPEvent($type);
            $eve->target = $this;
            $eve->data = $data;
            $listener($eve);
        });
    }

    public function removeEventListener($type, $listener, $capture = false)
    {
        // not implemented
    }

    public function dispatchEvent($event)
    {
        // not implemented
    }
}