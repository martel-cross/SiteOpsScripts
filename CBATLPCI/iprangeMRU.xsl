<?xml version="1.0"?> 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="MRU/IPRanges">
		<xsl:for-each select="IPRange">
			<xsl:sort select="@date" order="descending"/>
			<xsl:if test="@add1 and @add1!=''">
			<xsl:if test="@add2 and @add2!=''">
				<option><xsl:value-of select="@add1"/> to <xsl:value-of select="@add2"/></option>
			</xsl:if>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>	
