<?php
namespace Slothsoft\Lang;

use Slothsoft\CMS\HTTPStream;

class TranslatorStream extends HTTPStream {
	
	protected $translation;
	public function __construct(Translation $translation) {
		$this->translation = $translation;
	}
	
	protected function parseStatus() {
		if ($this->translation->hasWords()) {
			$this->setStatusContent();
		} else {
			$this->setStatusDone();
		}
	}
	
	protected function parseContent() {
		$word = $this->translation->nextWord();
		$this->content = json_encode($word);
	}
}