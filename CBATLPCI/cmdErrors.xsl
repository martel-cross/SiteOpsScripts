<?xml version="1.0"?> 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
		
<xsl:variable name="CR" select="'
'"/>
<xsl:variable name="SP" select="' '"/>
<xsl:template match="/">
	<xsl:for-each select="Errors">
		<xsl:apply-templates/>
	</xsl:for-each>
</xsl:template>
	
<xsl:template match="Error">
	 <xsl:choose>
		<xsl:when test="@Machine"><xsl:value-of select="@Domain"/>\<xsl:value-of select="@Machine"/><xsl:value-of select="$SP"/></xsl:when>
	 </xsl:choose>
	 <xsl:choose>
	 <xsl:when test="@IP">(<xsl:value-of select="@IP"/>)<xsl:value-of select="$SP"/></xsl:when>
	 </xsl:choose>	
	 <xsl:value-of select="."/>
	 <xsl:value-of select="$CR"/>
</xsl:template>
	
</xsl:stylesheet>