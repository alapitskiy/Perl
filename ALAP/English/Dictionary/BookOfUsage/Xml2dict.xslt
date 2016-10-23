<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:func="urn:func"
								extension-element-prefixes="func">

	<xsl:output cdata-section-elements="text" method="text" version="1.0" encoding="UTF-8" indent="yes"/>

	<xsl:param name="filename"/>

	<xsl:template match="/">
		<xsl:call-template name="title"/>
		<xsl:call-template name="body"/>
	</xsl:template>

	<xsl:template name="title">
		<xsl:variable name="end_ch" select="//comment[contains(.,'END CHAPTERTITLE')][1]"/>
		<xsl:variable name="title" select="$end_ch/preceding-sibling::tr[1]//a[@name]/text"/>

		<xsl:value-of select="$title"/>

		<xsl:variable name="subtitle" select="$end_ch/preceding-sibling::tr[2]//text"/>
		<xsl:call-template name="new_line"/>

		<xsl:call-template name="indent"/>
		<xsl:value-of select="'[m0][*][ex]'"/>
		<xsl:for-each select="$subtitle">
			<xsl:call-template name="print-one-line"/>
		</xsl:for-each>
		<xsl:value-of select="'[/ex][/*][/m]'"/>

		<xsl:call-template name="check_empty">
			<xsl:with-param name="var" select="$title"/>
			<xsl:with-param name="section" select="'title'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="body">
		<xsl:variable name="begin_ch" select="//comment[. = 'BEGIN CHAPTER'][1]"/>
		<xsl:variable name="trs" select="$begin_ch//following-sibling::tr[normalize-space()]"/>
		<!-- Select number -->
		<xsl:for-each select="$trs">
			<xsl:variable name="sect_num" select="normalize-space(td[last()]//a/@name)"/>

			<xsl:call-template name="new_line"/>
			<xsl:call-template name="indent"/>
			<xsl:value-of select="'[b]'"/>
			<xsl:value-of select="$sect_num"/>
			<xsl:value-of select="'. [/b] '"/>

			<!-- Here can be empty (see C002/007)
			<xsl:call-template name="check_empty">
				<xsl:with-param name="var" select="$sect_num"/>
				<xsl:with-param name="section" select="'sect_num'"/>
			</xsl:call-template>
		  -->
			<xsl:apply-templates select="td[1]"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="td">
		<xsl:apply-templates select="*[self::i or self::table or self::a or self::img or self::text]"/>
	</xsl:template>

	<xsl:template match="table">
		<xsl:call-template name="new_line"/>
		<xsl:for-each select="*[self::tr]">
			<xsl:if test="normalize-space(.)">
				<xsl:value-of select="'&#x09;[m2][*][ex]&quot;'"/>
				<xsl:apply-templates select="td[position() != 1]"/>
				<xsl:value-of select="'&quot;[/ex][/*][/m]&#x0A;'"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="i">
		<xsl:value-of select="'[i]'"/>
		<xsl:apply-templates select="*[self::a or self::text or self::img]"/>
		<xsl:value-of select="'[/i]'"/>
	</xsl:template>

	<xsl:template match="a">
		<xsl:value-of select="'[u]'"/>
		<xsl:apply-templates select="*[self::i or self::text or self::img]"/>
		<xsl:value-of select="'[/u]'"/>
	</xsl:template>

	<xsl:template match="img">
		<xsl:value-of select="'[g]'"/>
		<xsl:value-of select="@src"/>
		<xsl:value-of select="'[/g]'"/>
	</xsl:template>

	<xsl:template match="text">
		<!-- <xsl:value-of select="';start_text_tag'"/> -->
		<xsl:call-template name="print-one-line"/>
		<!-- <xsl:value-of select="';end_text_tag'"/> -->
	</xsl:template>

	<xsl:template name="print-one-line">
		<!-- <xsl:value-of select="';print-one-line'"/> -->
		<xsl:if test="normalize-space(.) or . = ' '">
			<!-- <xsl:value-of select="';start_print'"/> -->
			<!--<xsl:value-of select="func:my_remove_ws(translate(translate(.,'&#x0A;',''),'&#x0D;', ''))"/>-->
			<xsl:value-of select="func:my_remove_ws(.)"/>
			<!-- <xsl:value-of select="';end_print'"/> -->
		</xsl:if>
	</xsl:template>

	<xsl:template name="indent">
		<xsl:value-of select="'&#x09;'"/>
	</xsl:template>

	<xsl:template name="new_line">
		<xsl:value-of select="'&#x0A;'"/>
	</xsl:template>

	<xsl:template name="check_empty">
		<xsl:param name="var"/>
		<xsl:param name="section"/>

		<xsl:if test="not($var)">
			<xsl:value-of select="concat('FUCK NO ', '&#x0A;')"/>
			<xsl:value-of select="concat('IN SSECTION ', $section)"/>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>