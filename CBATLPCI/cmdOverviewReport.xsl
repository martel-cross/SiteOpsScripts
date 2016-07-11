<?xml version="1.0"?> 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:variable name="ScoreLookup">
	<c score="0" text.loc="report.text.1" text="Check Not Performed"/>
	<c score="1" text.loc="report.text.2" text="Unable to scan"/>
	<c score="2" text.loc="report.text.3" text="Check failed (critical)"/>
	<c score="3" text.loc="report.text.4" text="Check failed (non-critical)"/>
	<c score="4" text.loc="report.text.5" text="Best practice"/>
	<c score="5" text.loc="report.text.6" text="Check passed"/>
	<c score="6" text.loc="report.text.7" text="Check not performed"/>
	<c score="7" text.loc="report.text.8" text="Additional information"/>
	<c score="8" text.loc="report.text.9" text="Not approved"/>
</xsl:variable>
	
<xsl:variable name="Assessment">
	<c score="1" text.loc="clirep.incompscan" text="Incomplete Scan"/>
	<c score="2" text.loc="clirep.severerisk" text="Severe Risk"/>
	<c score="3" text.loc="clirep.potentrisk" text="Potential Risk"/>
	<c score="4" text.loc="clirep.securefyi" text="Security FYIs"/>
	<c score="5" text.loc="clirep.strongsec" text="Strong Security"/>
	<c score="6" text.loc="clirep.checknotdone" text="Check Not Performed"/>
	<c score="7" text.loc="clirep.additioninfo" text="Additional Information"/>
	<c score="8" text.loc="clirep.securefyi" text="Security FYIs"/>
</xsl:variable>

<xsl:variable name="CR" select="'
'"/>

<xsl:variable name="FileName">FileNameHere</xsl:variable>

<xsl:template match="SecScan">

<xsl:param name="assess" select="@Grade"/>
Security assessment: <xsl:value-of select="document('')/*/xsl:variable[@name='Assessment']/c[@score=$assess]/@text"/>					
Computer name: <xsl:value-of select="@Domain"/>\<xsl:value-of select="@Machine"/>
IP address: <xsl:value-of select="@IP"/>
Security report name: <xsl:value-of select="$FileName" />
<xsl:if test="@SUSServer and @SUSServer != ''">
WSUS server: <xsl:value-of select="@SUSServer" />
</xsl:if>
Scan date: <xsl:value-of select="@LDate"/>
Scanned with MBSA version: <xsl:value-of select="@MbsaToolVersion"/>
<xsl:choose><xsl:when test="@HotfixDataVersion">
Catalog synchronization date: <xsl:value-of select="@HotfixDataVersion"/>
</xsl:when></xsl:choose>
<xsl:if test="@WUSSource and @WUSSource != ''">
Security update catalog: <xsl:value-of select="@WUSSource" />
</xsl:if>

<xsl:if test="count(//AdditCabs/Cab) > 0">
	<xsl:for-each select="//AdditCabs/Cab">
		<xsl:value-of select="$CR"/>
		<xsl:value-of select=" @Prop"/>
	</xsl:for-each>
</xsl:if>

<xsl:for-each select="//Check[@DataVersionName and @DataVersion]">
<xsl:value-of select="$CR"/>
<xsl:value-of select="@DataVersionName"/><xsl:text> </xsl:text><xsl:value-of select="@DataVersion"/>
</xsl:for-each>

<xsl:choose>
<xsl:when test="Check[@Type='5']">

  Security Updates Scan Results
	<xsl:choose>
	<xsl:when test="Check[@Type='5'][@Cat='1']">
		<xsl:for-each select=".">
			<xsl:apply-templates select="Check[@Type='5'][@Cat='1']">
			</xsl:apply-templates>
		</xsl:for-each>	
	</xsl:when>
	</xsl:choose>
</xsl:when>
</xsl:choose>
<xsl:choose>
<xsl:when test="Check[@Type='1']">

  Operating System Scan Results 
	<xsl:choose>
	<xsl:when test="Check[@Type='1'][@Cat='1']">
    Administrative Vulnerabilities
		<xsl:for-each select=".">
			<xsl:apply-templates select="Check[@Type='1'][@Cat='1']">
			</xsl:apply-templates>
		</xsl:for-each>	
	</xsl:when>
	</xsl:choose>
	<xsl:choose>
	<xsl:when test="Check[@Type='1'][@Cat='2']">
	Additional System Information
		<xsl:for-each select=".">
			<xsl:apply-templates select="Check[@Type='1'][@Cat='2']">
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:when>
	</xsl:choose>
</xsl:when>
</xsl:choose>
<xsl:choose>
<xsl:when test="Check[@Type='3']">

  Internet Information Services (IIS) Scan Results
	<xsl:choose>
		<xsl:when test="Check[@Type='3'][@Cat='4']">
		<xsl:for-each select=".">
			<xsl:value-of select="Check[@Type='3'][@Cat='4']/Advice" />
		</xsl:for-each>
	</xsl:when>
	<xsl:when test="Check[@Type='3'][@Cat='1']">
	Administrative Vulnerabilities
		<xsl:for-each select=".">
			<xsl:apply-templates select="Check[@Type='3'][@Cat='1']">	
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:when>
	</xsl:choose>
	<xsl:choose>
	<xsl:when test="Check[@Type='3'][@Cat='2']">
	Additional System Information
		<xsl:for-each select=".">
			<xsl:apply-templates select="Check[@Type='3'][@Cat='2']">
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:when>
	</xsl:choose>
</xsl:when>
</xsl:choose>
<!-- One tag per SQL Instance, MBSA V1.1 and later -->
<xsl:choose>
	<xsl:when test="SQLInstance">

  SQL Server Scan Results<xsl:for-each select="."><xsl:apply-templates select="SQLInstance"/></xsl:for-each>
	</xsl:when>
</xsl:choose>
<xsl:choose>
<xsl:when test="Check[@Type='2']">

  SQL Server Scan Results
	<xsl:choose>
	<xsl:when test="Check[@Type='2'][@Cat='4']">
		<xsl:for-each select=".">
			<xsl:value-of select="Check[@Type='2'][@Cat='4']/Advice" />
		</xsl:for-each>
	</xsl:when>
	<xsl:when test="Check[@Type='2'][@Cat='1']">
	Administrative Vulnerabilities
		<xsl:for-each select=".">
			<xsl:apply-templates select="Check[@Type='2'][@Cat='1']">		
			</xsl:apply-templates>
		</xsl:for-each>	
	</xsl:when>
	</xsl:choose>
	<xsl:choose>
	<xsl:when test="Check[@Type='2'][@Cat='2']">
	Additional System Information
		<xsl:for-each select=".">
			<xsl:apply-templates select="Check[@Type='2'][@Cat='2']">	
			</xsl:apply-templates>
		</xsl:for-each>	
	</xsl:when>
	</xsl:choose>
</xsl:when>
</xsl:choose>
<xsl:choose>
<xsl:when test="Check[@Type='4']">

  Desktop Application Scan Results
	<xsl:choose>
	<xsl:when test="Check[@Type='4'][@Cat='1']">
	Administrative Vulnerabilities
		<xsl:for-each select=".">
			<xsl:apply-templates select="Check[@Type='4'][@Cat='1']">
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:when>
	</xsl:choose>
	<xsl:choose>
	<xsl:when test="Check[@Type='4'][@Cat='2']">
	Additional System Information
		<xsl:for-each select=".">
			<xsl:apply-templates select="Check[@Type='4'][@Cat='2']">
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:when>
	</xsl:choose>
</xsl:when>
</xsl:choose>
<xsl:value-of select="$CR"/>
</xsl:template>
	
<!-- SQL Instance section -->
<xsl:template match="SQLInstance">

   Instance <xsl:value-of select="@Name"/>
	<xsl:choose>
	<xsl:when test="Check[@Type='2'][@Cat='1']">

    Administrative Vulnerabilities
		<xsl:for-each select=".">
			<xsl:apply-templates select="Check[@Type='2'][@Cat='1']">
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:when>
	</xsl:choose>
	<xsl:choose>
	<xsl:when test="Check[@Type='2'][@Cat='2']">

    Additional System Information
		<xsl:for-each select=".">
			<xsl:apply-templates select="Check[@Type='2'][@Cat='2']">
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template match="Check">
<xsl:param name="score" select="@Grade"/>
   	   Issue:  <xsl:value-of select="@Name"/>
	   Score:  <xsl:value-of select="document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=$score]/@text"/>
	   Result: <xsl:value-of select="Advice"/>
</xsl:template>
</xsl:stylesheet>
