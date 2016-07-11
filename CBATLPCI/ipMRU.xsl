<?xml version="1.0"?> 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="MRU/IPs">
		<xsl:for-each select="IP">
			<xsl:sort select="@date" order="descending"/>
			<option><xsl:value-of select="@addr"/></option>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>		