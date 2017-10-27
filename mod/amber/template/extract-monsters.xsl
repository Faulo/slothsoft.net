<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	xmlns:func="http://exslt.org/functions"
	xmlns:str="http://exslt.org/strings"
	xmlns:php="http://php.net/xsl"
	xmlns:save="http://schema.slothsoft.net/savegame"
	extension-element-prefixes="exsl func str set php">
	
	<xsl:key name="dictionary-option" match="save:savegame.editor/save:dictionary/save:option" use="../@dictionary-id"/>
	<xsl:template match="save:savegame.editor">
		<xsl:for-each select="$categories">
	</xsl:template>
	
	<xsl:template match="*" mode="extract">
			attack="{*[@name = 'attack']/@value + *[@name = 'combat-attack']/@value}"
			defense="{*[@name = 'defense']/@value + *[@name = 'combat-defense']/@value}"
			>
			<xsl:apply-templates select=".//*[@name = 'name']" mode="attr"/>
			<xsl:apply-templates select=".//*[@name = 'level']" mode="attr"/>
			<xsl:apply-templates select=".//*[@name = 'attacks-per-round']" mode="attr"/>
			<xsl:apply-templates select=".//*[@name = 'gold']" mode="attr"/>
			<xsl:apply-templates select=".//*[@name = 'food']" mode="attr"/>
			<xsl:apply-templates select=".//*[@name = 'combat-experience']" mode="attr"/>
			<xsl:apply-templates select=".//*[@name = 'magic-attack']" mode="attr"/>
			<xsl:apply-templates select=".//*[@name = 'magic-defense']" mode="attr"/>
			<xsl:for-each select=".//*[@name = 'monster-type']/*[@value]">
				<xsl:attribute name="is-{@name}"/>
			</xsl:for-each>
			<race>
				<xsl:apply-templates select=".//*[@name = 'race']" mode="attr">
					<xsl:with-param name="name" select="'name'"/>
				</xsl:apply-templates>
				<xsl:apply-templates select=".//*[@name = 'age']//*[@name = 'current']" mode="attr">
					<xsl:with-param name="name" select="'current-age'"/>
				</xsl:apply-templates>
				<xsl:apply-templates select=".//*[@name = 'age']//*[@name = 'maximum']" mode="attr">
					<xsl:with-param name="name" select="'maximum-age'"/>
				</xsl:apply-templates>
				<xsl:for-each select=".//*[@name = 'attributes']/*">
					<attribue name="{@name}"
						current="{*[@name = 'current']/@value + *[@name = 'current-mod']/@value}" maximum="{*[@name = 'current']/@value}"/>
				</xsl:for-each>
			</race>
			<class>
				<xsl:apply-templates select=".//*[@name = 'name']" mode="attr">
					<xsl:with-param name="name" select="'name'"/>
				</xsl:apply-templates>
				<xsl:apply-templates select=".//*[@name = 'school']" mode="attr"/>
				<xsl:apply-templates select=".//*[@name = 'apr-per-level']" mode="attr"/>
				<xsl:apply-templates select=".//*[@name = 'hp-per-level']" mode="attr"/>
				<xsl:apply-templates select=".//*[@name = 'sp-per-level']" mode="attr"/>
				<xsl:apply-templates select=".//*[@name = 'tp-per-level']" mode="attr"/>
				<xsl:apply-templates select=".//*[@name = 'slp-per-level']" mode="attr"/>
				<xsl:for-each select=".//*[@name = 'skills']/*">
					<skill name="{@name}"
						current="{*[@name = 'current']/@value + *[@name = 'current-mod']/@value}" maximum="{*[@name = 'current']/@value}"/>
				</xsl:for-each>
			</class>
			<xsl:apply-templates select=".//*[@name = 'gfx']" mode="extract"/>
	</xsl:template>
	
	<xsl:template match="*[@name = 'gfx']" mode="extract">
		<xsl:variable name="width" select=".//*[@name = 'gfx-width']"/>
		<xsl:variable name="height" select=".//*[@name = 'gfx-height']"/>
		<xsl:variable name="animationCycles" select=".//*[@name = 'cycle']"/>
		<xsl:variable name="animationLengths" select=".//*[@name = 'length']"/>
		<xsl:variable name="animationMirrors" select=".//*[@name = 'mirror']/*"/>
		
		<gfx id="{.//*[@name='gfx-id']/@value}" 
			sourge-width="{$width/*[@name = 'source']/@value}" source-height="{$height/*[@name = 'source']/@value}"
			target-width="{$width/*[@name = 'target']/@value}" target-height="{$height/*[@name = 'target']/@value}">
			<xsl:for-each select="$animationCycles">
				<xsl:variable name="pos" select="position()"/>
				<xsl:variable name="length" select="$animationLengths[$pos]/@value"/>
				<animation name="{../@name}">
					<xsl:for-each select="str:tokenize(@value)[position() &lt;= $length]">
						<frame offset="{php:functionString('hexdec', .)}"/>
					</xsl:for-each>
					<xsl:if test="$animationMirrors[$pos]/@value">
						<xsl:for-each select="str:tokenize(@value)[position() &lt;= $length]">
							<xsl:sort select="position()" order="descending"/>
							<frame offset="{php:functionString('hexdec', .)}"/>
						</xsl:for-each>
					</xsl:if>
				</animation>
			</xsl:for-each>
		</gfx>
	</xsl:template>
		<xsl:param name="name" select="@name"/>
		<xsl:param name="name" select="@name"/>
</xsl:stylesheet>