<?php
namespace Slothsoft\CMS;

use Slothsoft\Amber\ModController;
$controller = new ModController(__DIR__ . '/..');

return $controller->extractAction($this->httpRequest);