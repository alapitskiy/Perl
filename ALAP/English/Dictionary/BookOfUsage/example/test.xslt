<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!--<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>-->

	<xsl:variable name="header">
		<tr>
			<th>Element</th>
			<th>Description</th>
		</tr>
	</xsl:variable>

	<xsl:template match="table">
		<!--<xsl:copy-of select="self::node()"/>-->
		<!--<xsl:copy-of select="$header"/>-->
		<!--<xsl:copy></xsl:copy>-->
		<!--<xsl:copy-of select="$header"/>-->
		<!--<xsl:text>fuckin bithc</xsl:text>-->
		<xsl:copy>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>