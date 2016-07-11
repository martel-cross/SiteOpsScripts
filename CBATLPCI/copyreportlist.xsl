<?xml version="1.0"?> 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:variable name="Assessment">
	  <c score="1" text.loc="reports.var.1" text="Incomplete Scan"/>
	  <c score="2" text.loc="reports.var.2" text="Severe Risk"/>
	  <c score="3" text.loc="reports.var.3" text="Potential Risk"/>
	  <c score="4" text.loc="reports.var.4" text="Security FYIs"/>
	  <c score="5" text.loc="reports.var.5" text="Strong Security"/>
	</xsl:variable>
	<xsl:template match="/">
		<table border="0" cellpadding="0" cellspacing="0" width="100%">
			<tr class="ReportListHeader">
				<td><B>Computer Name</B></td>
				<td><B>IP Address</B></td>
				<td><B>Assessment</B></td>
				<td><B>Scan Date</B></td>
			</tr>
			<xsl:for-each select="Reports">
				<xsl:apply-templates>
					<xsl:sort order="sortorder" select="sortfield"/>
				</xsl:apply-templates>
			</xsl:for-each>
		</table>
	</xsl:template>
	
	<xsl:template match="Report">
		<xsl:param name="score" select="@grade"/>
	
		<tr>
			<td><xsl:value-of select="@computer"/></td>
			<td><xsl:value-of select="@ip"/></td>
			<td><xsl:value-of select="document('')/*/xsl:variable[@name='Assessment']/c[@score=$score]/@text"/></td>
			<td>
			 <xsl:choose>
			  <xsl:when test="@ldate">
				<xsl:value-of select="@ldate"/>
			  </xsl:when>
			  <xsl:otherwise>
				<xsl:value-of select="@date"/>
			  </xsl:otherwise>
			 </xsl:choose>		
			</td>
		</tr>
		
	</xsl:template>
	
</xsl:stylesheet>
