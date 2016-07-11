<?xml version="1.0"?> 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
		
	<xsl:template match="/">
		<html>
		<head>
			<link REL="stylesheet" type="text/css" href="css/scanner.css" />
		</head>
		<body style="BORDER-RIGHT: 0px; MARGIN: 0px; OVERFLOW: auto">
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<xsl:for-each select="Errors">
					<xsl:apply-templates/>
				</xsl:for-each>
			</table>
		</body>
		</html>
	</xsl:template>
	
	<xsl:template match="Error">
		<tr>
			<td>
			 <xsl:choose>
				<xsl:when test="@DisplayName">
					<xsl:value-of select="@DisplayName"/>
				</xsl:when>
				<xsl:otherwise>
					 <xsl:choose>
						<xsl:when test="@Machine">
							<xsl:value-of select="@Domain"/>\<xsl:value-of select="@Machine"/>
						</xsl:when>
					 </xsl:choose>
				</xsl:otherwise>
			 </xsl:choose>				
			 <xsl:choose>
			 <xsl:when test="@IP">
				(<xsl:value-of select="@IP"/>)
			 </xsl:when>
			 </xsl:choose>	
			 <xsl:value-of select="."/><br />
			</td>
		</tr>
	</xsl:template>
	
</xsl:stylesheet>
