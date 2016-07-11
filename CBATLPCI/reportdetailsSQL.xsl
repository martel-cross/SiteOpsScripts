<?xml version="1.0"?> 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:variable name="CheckID" select="'CheckIDHere'"></xsl:variable>
	<xsl:variable name="InstanceName" select="'InstanceNameHere'"></xsl:variable>

	<xsl:variable name="ScoreLookup">
	  <c score="0" url="Graphics/dash.gif" alttext.loc="reportdetailsql.text.1" alttext="Check Not Performed"/>
	  <c score="1" url="Graphics/excl_red16.gif" alttext.loc="reportdetailsql.text.2" alttext="Unable to scan"/>
	  <c score="2" url="Graphics/mini_x_red.gif" alttext.loc="reportdetailsql.text.3" alttext="Check failed (critical)"/>
	  <c score="3" url="Graphics/mini_x_gold.gif" alttext.loc="reportdetailsql.text.4" alttext="Check failed (non-critical)"/>
	  <c score="4" url="Graphics/info.gif" alttext.loc="reportdetailsql.text.5" alttext="Best practice"/>
	  <c score="5" url="Graphics/mini_chek_grn.gif" alttext.loc="reportdetailsql.text.6" alttext="Check passed"/>
	  <c score="7" url="Graphics/info.gif" alttext.loc="reportdetailsql.text.7" alttext="Additional information"/>
	  <c score="8" url="Graphics/mini_star_blu.gif" alttext.loc="reportdetailsql.text.8" alttext="Not approved"/>
	</xsl:variable>
	
	<xsl:template match="SecScan">
		<xsl:choose>
		<xsl:when test='SQLInstance[@Name=$InstanceName]'>
			<h1><xsl:value-of select="SQLInstance[@Name=$InstanceName]/Check[@ID=$CheckID]/Advice"/></h1>
			<h2>Result Details for SQL Instance  <!--argstart instance--><xsl:value-of select="$InstanceName"/><!--argend--><br /><br /><xsl:value-of select="Check[@ID=$CheckID]/Detail/@text"/></h2>
			<table id="TableID" width="100%" border="0" cellpadding="0" cellspacing="0" style="padding-right: 10px;">
			<tr>
				<td class="DetailHeader" style="width:40;padding-left:10" valign="middle"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
				<xsl:for-each select="SQLInstance[@Name=$InstanceName]/Check[@ID=$CheckID]/Detail/Head/Col">
					<td class="DetailHeader" style ="padding-left:10" nowrap="nowrap">
						<xsl:value-of select="."/>&#160;
					</td>
				</xsl:for-each>
			</tr>
			
			<xsl:for-each select="SQLInstance[@Name=$InstanceName]/Check[@ID=$CheckID]/Detail">
				<xsl:apply-templates select="Row">
				</xsl:apply-templates>
			</xsl:for-each>
			</table>
		</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Row">
	<xsl:param name="score" select="@Grade"/>
		<tr>
			<td valign="top" align="center">
				<xsl:choose>
				  <xsl:when test="../../@ID='121'">
					<img alt="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=7]/@alttext}" src="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=7]/@url}" />
				  </xsl:when>
				  <xsl:otherwise>
					<IMG alt="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=$score]/@alttext}" src="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=$score]/@url}" />
				  </xsl:otherwise>
				</xsl:choose>	
			</td>
			<xsl:for-each select="Col">
			<td valign="top">
			 <xsl:choose>
			  <xsl:when test="@URL and @URL != '' and @URL != ' '">
				<A target="_blank" href="{@URL}"><xsl:value-of select="."/></A>
			  </xsl:when>
			  <xsl:otherwise>
				<xsl:value-of select="."/>
			  </xsl:otherwise>
			</xsl:choose>	
			</td>
			</xsl:for-each>
		</tr>
	</xsl:template>
	
</xsl:stylesheet>
