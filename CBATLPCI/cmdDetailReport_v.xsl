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

	<xsl:variable name="SeverityLookup">
		<c value="4" text.loc="reportdetailcmd.sev.4" text="Critical"/>
		<c value="3" text.loc="reportdetailcmd.sev.3" text="Important"/>
		<c value="2" text.loc="reportdetailcmd.sev.2" text="Moderate"/>
		<c value="1" text.loc="reportdetailcmd.sev.1" text="Low"/>
		<c value="0" text.loc="reportdetailcmd.sev.0" text=""/>
	</xsl:variable>

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
			<xsl:apply-templates select="Check[@ID='500']" mode="wus"/>
			<xsl:apply-templates select="Check[@ID!='500' and @Type='5'][@Cat='1']"/>
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
	   <xsl:if test="Detail">
	   Detail:
			| <xsl:for-each select="Detail/Head/Col"><xsl:value-of select="."/> | </xsl:for-each>
			<xsl:for-each select="Detail/Row">

			<xsl:choose>
			
			<xsl:when test="Col[1]=' ' and Col[2]=' ' and Col[3]!=' '">
			| | <xsl:value-of select="Col[3]"/> | |</xsl:when>
			
			<xsl:otherwise>
			| <xsl:for-each select="Col"><xsl:value-of disable-output-escaping="yes" select="."/><xsl:if test="@REQUIREDNAME"> (This update requires <!-- argstart clirep.mustinst.requiredpatchname --><xsl:value-of select="@REQUIREDNAME"/> <!-- argend --> to be installed first.) </xsl:if> | </xsl:for-each>
			</xsl:otherwise>
			
			</xsl:choose>

			<xsl:if test="SETTINGS">
			Sub-Detail:
				| <xsl:for-each select="SETTINGS/Head/Col"><xsl:value-of select="."/> | </xsl:for-each>
				<xsl:for-each select="SETTINGS/Row">
				| <xsl:for-each select="Col"><xsl:value-of select="."/> | </xsl:for-each>
				</xsl:for-each>
			</xsl:if>
			</xsl:for-each> 
		</xsl:if>
    <xsl:value-of select="$CR"/>
</xsl:template>

<xsl:template match="Check" mode="wus">
<xsl:param name="score" select="@Grade"/>
 	   Issue:  <xsl:value-of select="@Name"/>
	   Score:  <xsl:value-of select="document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=$score]/@text"/>
	   Result: <xsl:value-of select="Advice"/><xsl:value-of select="$CR"/>

	<!-- 1st section: Missing critical updates -->
	<xsl:if test="count(Detail/UpdateData[(@IsInstalled='false' or @RestartRequired='true') and @Type=1]) > 0">
		Security Updates			
		<xsl:apply-templates select="Detail/UpdateData[(@IsInstalled='false' or @RestartRequired='true') and @Type=1]" />
		<xsl:value-of select="$CR"/>
	</xsl:if>
	<!-- 2nd section: Missing rollups and service packs -->
	<xsl:if test="count(Detail/UpdateData[(@IsInstalled='false' or @RestartRequired='true') and @Type!=1]) > 0">
		Update Rollups and Service Packs
		<xsl:apply-templates select="Detail/UpdateData[(@IsInstalled='false' or @RestartRequired='true') and @Type!=1]" />
		<xsl:value-of select="$CR"/>
	</xsl:if>
	<!-- 3rd section: Installed items -->
	<xsl:if test="count(Detail/UpdateData[@IsInstalled='true' and (not(@RestartRequired) or @RestartRequired='false')]) > 0">
		Current Update Compliance
		<xsl:apply-templates select="Detail/UpdateData[@IsInstalled='true' and (not(@RestartRequired) or @RestartRequired='false')]" />
		<xsl:value-of select="$CR"/>
	</xsl:if>	
</xsl:template>

<xsl:template match="UpdateData">
<xsl:param name="score" select="@Grade"/>
	<xsl:variable name="SevValue"><xsl:value-of select="@Severity"/></xsl:variable>
	<xsl:variable name="Approved"><xsl:value-of select="@WUSApproved"/></xsl:variable>
	<xsl:variable name="GradeText">
		<xsl:choose>
			<xsl:when test="@IsInstalled='true'">Installed</xsl:when>
			<xsl:when test="@IsInstalled='false' and not(@WUSApproved)">Missing</xsl:when>
			<xsl:when test="@IsInstalled='false' and @WUSApproved='true'">Missing</xsl:when>
			<xsl:when test="@IsInstalled='false' and @WUSApproved='false'">Not Approved</xsl:when>
			<xsl:otherwise></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
			| <xsl:value-of select="@ID"/> | <xsl:value-of select="$GradeText"/> | <xsl:value-of select="Title"/> | <xsl:value-of select="document('')/*/xsl:variable[@name='SeverityLookup']/c[@value=$SevValue]/@text"/> | </xsl:template>
</xsl:stylesheet>
