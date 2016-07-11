<?xml version="1.0"?> 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:variable name="Assessment">
  <c score="1" text.loc="clirep.incompscan" text="Incomplete Scan"/>
  <c score="2" text.loc="clirep.severerisk" text="Severe Risk"/>
  <c score="3" text.loc="clirep.potentrisk" text="Potential Risk"/>
  <c score="4" text.loc="clirep.securefyi" text="Security FYIs"/>
  <c score="5" text.loc="clirep.strongsec" text="Strong Security"/>
</xsl:variable>
<xsl:variable name="CR" select="'
'"/>
<xsl:template match="/">

Computer Name,  IP Address,  Assessment,  Report Name
-----------------------------------------------------
<xsl:for-each select="Reports">
<xsl:apply-templates>
</xsl:apply-templates>
</xsl:for-each>
</xsl:template>
	
<xsl:template match="Report">
	<xsl:param name="score" select="@grade"/>
	<xsl:value-of select="@computer"/>, <xsl:value-of select="@ip"/>, <xsl:value-of select="document('')/*/xsl:variable[@name='Assessment']/c[@score=$score]/@text"/>, <xsl:value-of select="@file"/><xsl:value-of select="$CR"/>
</xsl:template>
	
</xsl:stylesheet>
