<?php
namespace Slothsoft\Savegame\Node;

use Ds\Vector;
use Slothsoft\Savegame\Converter;
use Slothsoft\Savegame\Editor;
use Slothsoft\Savegame\EditorElement;
use Slothsoft\Savegame\Build\BuildableInterface;
declare(ticks = 1000);

abstract class AbstractNode
{

    abstract protected function loadNode(EditorElement $strucElement);

    /**
     *
     * @var \Slothsoft\Savegame\Node\AbstractNode
     */
    private $parentNode;

    private $childNodeList;

    public function __construct()
    {}

    public function init(EditorElement $strucElement, AbstractNode $parentNode = null)
    {
        $this->parentNode = $parentNode;
        
        if ($this->parentNode and $this instanceof BuildableInterface) {
            $this->parentNode->appendBuildChild($this);
        }
        
        $this->loadStruc($strucElement);
        $this->loadNode($strucElement);
        $this->loadChildren($strucElement);
    }

    protected function loadStruc(EditorElement $strucElement)
    {}

    protected function loadChildren(EditorElement $strucElement)
    {
        foreach ($strucElement->getChildren() as $strucElement) {
            $this->loadChild($strucElement);
        }
    }

    protected function loadChild(EditorElement $strucElement)
    {
        if ($node = $this->getOwnerEditor()->createNode($this, $strucElement)) {
            // echo get_class($node) . PHP_EOL;
        }
    }

    /**
     *
     * @return \Slothsoft\Savegame\Editor
     */
    public function getOwnerEditor(): Editor
    {
        return $this->getOwnerSavegame()->getOwnerEditor();
    }

    /**
     *
     * @return \Slothsoft\Savegame\Node\SavegameNode
     */
    public function getOwnerSavegame(): SavegameNode
    {
        return $this->parentNode instanceof SavegameNode ? $this->parentNode : $this->parentNode->getOwnerSavegame();
    }

    /**
     *
     * @return \Slothsoft\Savegame\Converter
     */
    protected function getConverter()
    {
        return Converter::getInstance();
    }

    public function getParentNode()
    {
        return $this->parentNode;
    }
	
	public function appendBuildChild(BuildableInterface $childNode) {
		if ($this instanceof BuildableInterface) {
            if ($this->childNodeList === null) {
                $this->childNodeList = new Vector();
            }
            $this->childNodeList[] = $childNode;
        } else {
            $this->parentNode->appendBuildChild($childNode);
        }
	}
	public function getBuildChildren()
    {
        return $this->childNodeList;
    }
}