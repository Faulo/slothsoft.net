<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet version="1.0"	xmlns="http://www.w3.org/1999/xhtml"	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"	xmlns:exslt="http://exslt.org/common"	xmlns:date="http://exslt.org/dates-and-times"	xmlns:lio="http://schema.slothsoft.net/xslt"	extension-element-prefixes="date lio">		<xsl:import href="/getTemplate.php/core/date.functions"/>		<xsl:variable name="dateStart" select="'2016-04-18T12:00:00+00:00'"/>	<xsl:variable name="dateFormat" select="'d.m.y'"/>		<xsl:template match="/data">		<html>			<head>				<title>Wochenziele</title>			</head>			<body>				<main>					<h1>Slothsoft's Wochenziele</h1>					<xsl:apply-templates select="*/clinic"/>				</main>			</body>		</html>	</xsl:template>		<xsl:template match="clinic">		<xsl:apply-templates select="patient"/>	</xsl:template>		<xsl:template match="patient">		<xsl:variable name="patientName" select="concat('[', @name, ']')"/>		<details>			<summary><h2><xsl:value-of select="@name"/></h2></summary>			<div>				<form method="POST">					<details>						<summary><h3>Zusammenfassung</h3></summary>												<xsl:for-each select="globalGoals/goal[@name != '']">							<div class="graph">								<xsl:apply-templates select="." mode="graph">									<xsl:with-param name="title">										<h3><xsl:value-of select="concat('Übergeordnetes Ziel ', position(), ': ', @name)"/></h3>									</xsl:with-param>									<xsl:with-param name="description">										<p><xsl:value-of select="@description"/></p>									</xsl:with-param>								</xsl:apply-templates>								<div>									<h3><xsl:value-of select="concat('Übergeordnetes Ziel ', position(), ': ', @name)"/></h3>									<p><xsl:value-of select="@description"/></p>								</div>							</div>						</xsl:for-each>						<ol>							<li>								<xsl:variable name="pos" select="0"/>								<h4>									Woche <xsl:value-of select="$pos"/>:									<xsl:call-template name="week-time">										<xsl:with-param name="offset" select="$pos"/>									</xsl:call-template>								</h4>								<h5>Übergeordnete Ziele</h5>								<ul>									<xsl:for-each select="globalGoals/goal[@name != '']">										<xsl:variable name="oldRating" select="rating[@value != ''][1][@value != '-']"/>										<xsl:if test="$oldRating">											<li>												<xsl:value-of select="concat('#', position(), ': ', @name, ' - ', $oldRating/@value, ' Punkte')"/>											</li>										</xsl:if>									</xsl:for-each>								</ul>							</li>							<xsl:for-each select="weeklyGoals[goal/@name != '']">								<xsl:variable name="pos" select="position()"/>								<li>									<h4>										Woche <xsl:value-of select="$pos"/>:										<xsl:call-template name="week-time">											<xsl:with-param name="offset" select="$pos"/>										</xsl:call-template>									</h4>																		<!--<xsl:if test="../globalGoals/goal/rating[@value != ''][$pos + 1]/@value">-->									<xsl:if test="../globalGoals/goal/rating[@value != ''][$pos + 1][@value != '-']">										<h5>Übergeordnete Ziele</h5>										<ul>											<xsl:for-each select="../globalGoals/goal[@name != '']">												<xsl:variable name="oldRating" select="rating[@value != ''][$pos + 0][@value != '-']"/>												<xsl:variable name="newRating" select="rating[@value != ''][$pos + 1][@value != '-']"/>												<xsl:if test="$newRating">													<li>														<xsl:value-of select="concat('#', position(), ': ', @name, ' - ')"/>														<xsl:value-of select="$oldRating/@value"/>														<xsl:if test="$oldRating and $newRating">															<xsl:text> » </xsl:text>														</xsl:if>														<xsl:value-of select="$newRating/@value"/>														<xsl:text> Punkte</xsl:text>														<!--														<xsl:value-of select="concat('#', position(), ': ', @name, ' - ', rating[@value != ''][$pos]/@value, ' » ', rating[@value != ''][$pos + 1]/@value, ' Punkte')"/>														-->													</li>												</xsl:if>											</xsl:for-each>										</ul>									</xsl:if>									<xsl:if test="goal[@name != '-']">										<!--<h5>Wochenziele</h5>-->										<ul>											<xsl:for-each select="goal[@name != '']">												<li>													<xsl:value-of select="concat('#', position(), ': ', @name)"/>													<xsl:if test="rating[@value != ''][last()]/@value">														<xsl:value-of select="concat(' - ', rating[@value != ''][last()]/@value, ' Punkte')"/>													</xsl:if>												</li>											</xsl:for-each>										</ul>									</xsl:if>								</li>							</xsl:for-each>						</ol>					</details>					<details>						<summary><h3>Übergeordnete Ziele</h3></summary>						<table>							<thead>								<tr>									<th data-width="10">#</th>									<th data-width="90">Ziel</th>								</tr>							</thead>							<xsl:for-each select="globalGoals">								<xsl:variable name="globalGoalsName" select="concat($patientName, '[globalGoals]')"/>								<tbody>									<xsl:for-each select="goal">										<xsl:variable name="pos" select="position()"/>										<xsl:variable name="goalName" select="concat($globalGoalsName, '[goal][', position(), ']')"/>										<tr>											<th rowspan="3"><xsl:value-of select="$pos"/></th>											<td class="input">												<xsl:call-template name="form.input">													<xsl:with-param name="node" select="."/>													<xsl:with-param name="name" select="concat($goalName, '[name]')"/>													<xsl:with-param name="value" select="string(@name)"/>												</xsl:call-template>											</td>										</tr>										<tr>											<td class="input">												<xsl:call-template name="form.input">													<xsl:with-param name="node" select="."/>													<xsl:with-param name="name" select="concat($goalName, '[description]')"/>													<xsl:with-param name="value" select="string(@description)"/>													<xsl:with-param name="type" select="'textarea'"/>												</xsl:call-template>											</td>										</tr>										<tr>											<td class="input inline">												<xsl:for-each select="rating">													<xsl:variable name="ratingName" select="concat($goalName, '[rating][', position(), ']')"/>													<xsl:call-template name="form.input">														<xsl:with-param name="node" select="."/>														<xsl:with-param name="name" select="concat($ratingName, '[value]')"/>														<xsl:with-param name="value" select="string(@value)"/>													</xsl:call-template>												</xsl:for-each>											</td>										</tr>									</xsl:for-each>								</tbody>							</xsl:for-each>						</table>						<input type="submit"/>					</details>					<details>						<summary><h3>Wochenziele</h3></summary>						<table>							<thead>								<tr>									<th data-width="10">Woche</th>									<th data-width="80">Ziele</th>									<th data-width="10">Punkte</th>								</tr>							</thead>							<xsl:variable name="weeklyGoals">								<xsl:for-each select="weeklyGoals">									<xsl:variable name="pos" select="position()"/>									<xsl:variable name="weeklyGoalsName" select="concat($patientName, '[weeklyGoals][', position(), ']')"/>									<tbody>										<xsl:for-each select="goal">											<xsl:variable name="goalName" select="concat($weeklyGoalsName, '[goal][', position(), ']')"/>											<tr>												<xsl:if test="position() = 1">													<th rowspan="{last()}">														<xsl:value-of select="$pos"/>														<xsl:call-template name="week-time">															<xsl:with-param name="offset" select="$pos"/>														</xsl:call-template>													</th>												</xsl:if>												<td class="input">													<xsl:call-template name="form.input">														<xsl:with-param name="node" select="."/>														<xsl:with-param name="name" select="concat($goalName, '[name]')"/>														<xsl:with-param name="value" select="string(@name)"/>													</xsl:call-template>												</td>												<td class="input">													<xsl:call-template name="form.input">														<xsl:with-param name="node" select="."/>														<xsl:with-param name="name" select="concat($goalName, '[rating][1][value]')"/>														<xsl:with-param name="value" select="string(rating/@value)"/>														<xsl:with-param name="type" select="'number'"/>													</xsl:call-template>												</td>											</tr>										</xsl:for-each>									</tbody>								</xsl:for-each>							</xsl:variable>							<xsl:for-each select="exslt:node-set($weeklyGoals)/*">								<xsl:sort select="position()" data-type="number" order="descending"/>								<xsl:copy-of select="."/>							</xsl:for-each>						</table>						<input type="submit"/>					</details>				</form>			</div>		</details>	</xsl:template>		<xsl:template name="form.input">		<xsl:param name="name"/>		<xsl:param name="node"/>		<xsl:param name="type" select="'text'"/>		<xsl:param name="value" select="''"/>		<xsl:choose>			<xsl:when test="$type = 'range'">				<label>					0					<input type="{$type}" value="{$value}" name="clinic{$name}" min="0" max="9" step="1"/>					9				</label>			</xsl:when>			<xsl:when test="$type = 'number'">				<input type="{$type}" value="{$value}" name="clinic{$name}" min="0" max="9" step="1"/>			</xsl:when>			<xsl:when test="$type = 'textarea'">				<textarea name="clinic{$name}"><xsl:value-of select="$value"/></textarea>			</xsl:when>			<xsl:otherwise>				<input type="{$type}" value="{$value}" name="clinic{$name}"/>			</xsl:otherwise>		</xsl:choose>	</xsl:template>		<xsl:template match="goal" mode="graph" xmlns="http://www.w3.org/2000/svg">		<xsl:param name="title" select="/.."/>		<xsl:param name="description" select="/.."/>		<xsl:variable name="ratingList" select="rating[@value != '']"/>				<xsl:variable name="scaleX" select="45"/>		<xsl:variable name="scaleY" select="30"/>		<xsl:variable name="minY" select="0"/>		<xsl:variable name="maxY" select="9"/>		<xsl:variable name="minX" select="0"/>		<xsl:variable name="maxX" select="count($ratingList)"/>		<xsl:variable name="width" select="round(($maxX - $minX + 3) * $scaleX)"/> <!-- round(($maxX - $minX + 2) * $scaleX) -->		<xsl:variable name="height" select="round(($maxY - $minY + 1.5) * $scaleY)"/>				<svg			contentScriptType="application/javascript"			contentStyleType="text/css"			color-rendering="optimizeSpeed"			shape-rendering="optimizeSpeed"			text-rendering="optimizeSpeed"			image-rendering="optimizeSpeed"			viewBox="0 0 {$width} {$height}"			>			<g transform="translate({$scaleX}, {($maxY + 0.5) * $scaleY}) scale(1, -1)">				<g class="online" >					<path color="green">						<xsl:attribute name="d">							<xsl:text>M</xsl:text>							<xsl:value-of select="$minX * $scaleX"/>							<xsl:text>,</xsl:text>							<xsl:value-of select="$minY * $scaleY"/>							<xsl:for-each select="$ratingList">								<xsl:variable name="pos" select="position()"/>								<xsl:choose>									<xsl:when test="@value != '-'">										<xsl:if test="$ratingList[$pos - 1]/@value = '-'">											<xsl:text> L</xsl:text>											<xsl:value-of select="round((position() - 2) * $scaleX)"/>											<xsl:text>,</xsl:text>											<xsl:value-of select="round(@value * $scaleY)"/>										</xsl:if>										<xsl:text> L</xsl:text>										<xsl:value-of select="round((position() - 1) * $scaleX)"/>										<xsl:text>,</xsl:text>										<xsl:value-of select="round(@value * $scaleY)"/>									</xsl:when>									<xsl:otherwise>										<xsl:text> L</xsl:text>										<xsl:value-of select="round((position() - 2) * $scaleX)"/>										<xsl:text>,</xsl:text>										<xsl:value-of select="0"/>										<xsl:text> L</xsl:text>										<xsl:value-of select="round((position() - 1) * $scaleX)"/>										<xsl:text>,</xsl:text>										<xsl:value-of select="0"/>									</xsl:otherwise>								</xsl:choose>							</xsl:for-each>							<xsl:text> L</xsl:text>							<xsl:value-of select="($maxX - 1) * $scaleX"/>							<xsl:text>,</xsl:text>							<xsl:value-of select="$minY * $scaleY"/>							<xsl:text> L</xsl:text>							<xsl:value-of select="$minX * $scaleX"/>							<xsl:text>,</xsl:text>							<xsl:value-of select="$minY * $scaleY"/>						</xsl:attribute>					</path>				</g>								<g class="axes">					<path fill="none" d="M{$minX * $scaleX},{$maxY * $scaleY} v{- $maxY * $scaleY} h{$maxX * $scaleX}"/>										<xsl:call-template name="graph-axis">						<xsl:with-param name="max" select="$maxX"/>						<xsl:with-param name="scaleX" select="$scaleX"/>						<xsl:with-param name="i" select="1"/>					</xsl:call-template>					<xsl:call-template name="graph-axis">						<xsl:with-param name="max" select="$maxY"/>						<xsl:with-param name="scaleY" select="$scaleY"/>						<xsl:with-param name="i" select="1"/>					</xsl:call-template>				</g>			</g>			<!--			<g class="title" transform="translate({1.5 * $scaleX}, {0 * $scaleY})">				<switch>					<foreignObject width="{$width}" height="{$height}" requiredExtensions="http://www.w3.org/1999/xhtml">						<xsl:copy-of select="$title"/>					</foreignObject>				</switch>			</g>			<g class="description" transform="translate({1.5 * $scaleX}, {2 * $scaleY})">				<switch>					<foreignObject width="{$width}" height="{$height}" requiredExtensions="http://www.w3.org/1999/xhtml">						<xsl:copy-of select="$description"/>					</foreignObject>				</switch>			</g>			-->		</svg>	</xsl:template>		<xsl:template name="graph-axis" xmlns="http://www.w3.org/2000/svg">		<xsl:param name="max"/>		<xsl:param name="scaleX" select="0"/>		<xsl:param name="scaleY" select="0"/>		<xsl:param name="i" select="0"/>		<rect transform="translate({$i * $scaleX - 1 - $scaleY div 4}, {$i * $scaleY - 1 - $scaleX div 4})" width="{2 + $scaleY div 2}" height="{2 + $scaleX div 2}"/>		<text transform="translate({$i * $scaleX - 1 - $scaleY div 2}, {$i * $scaleY - 1 - $scaleX div 2}) rotate(0) scale(1, -1)" text-anchor="middle" dominant-baseline="central">			<xsl:value-of select="$i"/>		</text>		<xsl:if test="$i &lt; $max">			<xsl:call-template name="graph-axis">				<xsl:with-param name="max" select="$max"/>				<xsl:with-param name="scaleX" select="$scaleX"/>				<xsl:with-param name="scaleY" select="$scaleY"/>				<xsl:with-param name="i" select="$i + 1"/>			</xsl:call-template>		</xsl:if>	</xsl:template>			<xsl:template name="week-time">		<xsl:param name="offset"/>				<span class="datetime">			<xsl:text> </xsl:text>			<time><xsl:value-of select="lio:date_format(date:add($dateStart, concat('P', 7 * $offset, 'D')), $dateFormat)"/></time>			<xsl:text> - </xsl:text>			<time><xsl:value-of select="lio:date_format(date:add($dateStart, concat('P', 7 * $offset + 6, 'D')), $dateFormat)"/></time>			<xsl:text></xsl:text>		</span>	</xsl:template>	</xsl:stylesheet>