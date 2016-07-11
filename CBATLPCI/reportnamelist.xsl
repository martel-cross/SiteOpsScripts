<?xml version="1.0"?> 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
	<xsl:for-each select="Reports">
		<xsl:apply-templates>
			<xsl:sort order="sortorder" select="sortfield" data-type="sortdata"/>
		</xsl:apply-templates>
	</xsl:for-each>
</xsl:template>

<xsl:template match="Report"><xsl:value-of select="@file"/>,</xsl:template>

</xsl:stylesheet>