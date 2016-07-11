<?xml version="1.0"?> 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:variable name="Assessment">
<c score="1" text.loc="reports.var.1" text="Incomplete Scan"/>
<c score="2" text.loc="reports.var.2" text="Severe Risk"/>
<c score="3" text.loc="reports.var.3" text="Potential Risk"/>
<c score="4" text.loc="reports.var.4" text="Security FYIs"/>
<c score="5" text.loc="reports.var.5" text="Strong Security"/>
<c score="8" text.loc="reports.var.4" text="Security FYIs"/>
</xsl:variable>
<xsl:template match="/">
<xsl:for-each select="Reports"><xsl:apply-templates><xsl:sort order="sortorder" select="sortfield"/></xsl:apply-templates>
</xsl:for-each>
</xsl:template>
<xsl:template match="Report">
<xsl:param name="score" select="@grade"/>
.
<xsl:value-of select="@computer"/> |	<xsl:value-of select="@ip"/> |	<xsl:value-of select="document('')/*/xsl:variable[@name='Assessment']/c[@score=$score]/@text"/> |	<xsl:choose>
			  <xsl:when test="@ldate">
				<xsl:value-of select="@ldate"/>
			  </xsl:when>
			  <xsl:otherwise>
				<xsl:value-of select="@date"/>
			  </xsl:otherwise>
			 </xsl:choose>
</xsl:template>
</xsl:stylesheet>
