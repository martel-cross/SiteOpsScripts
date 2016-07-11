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
		<html>
		<head>
			<link REL="stylesheet" type="text/css" href="css/scanner.css" />
		</head>
		<body style="BORDER-RIGHT: 0px; MARGIN: 0px; OVERFLOW: auto">
		<xsl:choose>
		    <xsl:when test="count(Reports/Report) = 0">
			There are no reports available.
		    </xsl:when>
		    <xsl:otherwise>
			<!--StartFragment -->
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr class="ReportListHeader">
					<td Style="PADDING-LEFT: 10px;"><B>Computer Name</B></td>
					<td width="5"><IMG SRC="Graphics/pixel.gif" WIDTH="5" HEIGHT="1" style="visibility:hidden"/></td>
					<td><B>IP Address</B></td>
					<td width="5"><IMG SRC="Graphics/pixel.gif" WIDTH="5" HEIGHT="1" style="visibility:hidden"/></td>
					<td><B>Assessment</B></td>
					<td width="5"><IMG SRC="Graphics/pixel.gif" WIDTH="5" HEIGHT="1" style="visibility:hidden"/></td>
					<td><B>Scan Date</B></td>
				</tr>
				<xsl:for-each select="Reports">
					<xsl:apply-templates>
						<xsl:sort order="sortorder" select="sortfield" data-type="sortdata"/>
					</xsl:apply-templates>
				</xsl:for-each>
			</table>
			<!--EndFragment -->
		    </xsl:otherwise>
		</xsl:choose>
		</body>
		</html>
	</xsl:template>
	
	<xsl:template match="Report">
		<xsl:param name="score" select="@grade"/>
		<xsl:variable name="classname">
			<xsl:choose>
				<xsl:when test="(position() mod 2) = 1">ReportsRowOverEven</xsl:when>
				<xsl:otherwise>ReportsRowOverOdd</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<tr	class="{$classname}" onmouseover="this.className='ReportsRowOverSelected';" onmouseout="this.className='{$classname}';">
			<td Style="PADDING-LEFT: 10px;"><A Style="WIDTH:100%;PADDING-LEFT: 1px;" href="javascript:void(0)" onkeydown="javascript:return keydown('{@file}','{position() -1}');" onclick="javascript:return onlinkenabled('{@file}','{position() -1}');" class="sys-link-normal"><xsl:value-of select="@computer"/></A></td>
			<td></td>
			<td Style="PADDING-TOP: 0.35em;" onclick="javascript:top.Header.OnNewLink('{@file}');javascript:parent.parent.OpenReport('{@file}','{position() -1}');"><xsl:value-of select="@ip"/></td>
			<td></td>
			<td Style="PADDING-TOP: 0.35em;" onclick="javascript:top.Header.OnNewLink('{@file}');javascript:parent.parent.OpenReport('{@file}','{position() -1}');"><xsl:value-of select="document('')/*/xsl:variable[@name='Assessment']/c[@score=$score]/@text"/></td>
			<td></td>
			<td Style="PADDING-RIGHT: 10px; PADDING-TOP: 0.35em;" onclick="javascript:top.Header.OnNewLink('{@file}');javascript:parent.parent.OpenReport('{@file}','{position() -1}');"><xsl:value-of select="@ldate"/></td>
		</tr>
		
	</xsl:template>
	
</xsl:stylesheet>
