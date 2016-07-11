<?xml version="1.0"?> 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:variable name="ScoreLookupHeader">
    <c score="0" url="Graphics/dash.gif" alttext.loc="report.text.1" alttext="Check Not Performed"/>
    <c score="1" url="Graphics/excl_red.gif" alttext.loc="report.text.2" alttext="Unable to scan"/>
    <c score="2" url="Graphics/x_red.gif" alttext.loc="report.text.3" alttext="Check failed (critical)"/>
    <c score="3" url="Graphics/x_gold.gif" alttext.loc="report.text.4" alttext="Check failed (non-critical)"/>
    <c score="4" url="Graphics/blueinfo32.gif" alttext.loc="report.text.5" alttext="Best practice"/>
    <c score="5" url="Graphics/chek_grn.gif" alttext.loc="report.text.6" alttext="Check passed"/>
    <c score="6" url="Graphics/dash.gif" alttext.loc="report.text.7" alttext="Check not performed"/>
    <c score="7" url="Graphics/blueinfo32.gif" alttext.loc="report.text.8" alttext="Additional information"/>
    <c score="8" url="Graphics/star_blu.gif" alttext.loc="report.text.9" alttext="Not approved"/>
  </xsl:variable>

  <xsl:variable name="Assessment">
	  <c score="1" text.loc="report.texta.1" text="Incomplete Scan" longtext.loc="report.longtext.1" longtext="Could not complete one or more requested checks."/>
	  <c score="2" text.loc="report.texta.2" text="Severe Risk" longtext.loc="report.longtext.2" longtext="One or more critical checks failed."/>
	  <c score="3" text.loc="report.texta.3" text="Potential Risk" longtext.loc="report.longtext.3" longtext="One or more non-critical checks failed."/>
	  <c score="4" text.loc="report.texta.4" text="Security FYIs" longtext.loc="report.longtext.4" longtext=""/>
	  <c score="5" text.loc="report.texta.5" text="Strong Security" longtext.loc="report.longtext.5" longtext="The selected checks were passed."/>
	  <c score="8" text.loc="report.texta.4" text="Security FYIs" longtext.loc="report.longtext.4" longtext=""/>
	</xsl:variable>

	<xsl:variable name="FileName"></xsl:variable>
	<xsl:variable name="ReportAgePH"></xsl:variable>
	<xsl:variable name="CatSyncAgePH"></xsl:variable>

<!-- The outermost tag -->
	<xsl:template match="SecScan">

		<!-- Add the report header information in a table -->
		<xsl:param name="assess" select="@Grade"/>
    
    <table>
      <tr>
        <td rowspan= "2">
          <img>
            <xsl:attribute name="src">
              <xsl:value-of select="document('')/*/xsl:variable[@name='ScoreLookupHeader']/c[@score=$assess]/@url"/>
            </xsl:attribute>
          </img>
        </td>
        <td class="reportsubheader" width="200">
          Security assessment:
        </td>
      </tr>
      <tr>
        <td class = "reportheader">
          <xsl:value-of select="document('')/*/xsl:variable[@name='Assessment']/c[@score=$assess]/@text"/><xsl:text> </xsl:text>(<xsl:value-of select="document('')/*/xsl:variable[@name='Assessment']/c[@score=$assess]/@longtext"/>)
        </td>
      </tr>
    </table>
    <HR/>
		<table>
		<tr>
			<td class="reportsubheader" width="200">Computer name:</td>
			<td>
				<xsl:choose>
					<xsl:when test="@DisplayName">
						<xsl:value-of select="@DisplayName"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@Domain"/>\<xsl:value-of select="@Machine"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
		</tr>
		<tr>
			<td class="reportsubheader" width="200">IP address:</td>
			<td><xsl:value-of select="@IP"/></td>
		</tr>
		<tr>
			<td class="reportsubheader" width="200">Security report name:</td>
			<td><xsl:value-of select="$FileName" /></td>
		</tr>
		<xsl:if test="@SUSServer and @SUSServer != ''">
			<tr>
				<td class="reportsubheader" width="200">WSUS server:</td>
				<td><xsl:value-of select="@SUSServer" /></td>
			</tr>
		</xsl:if>
		<tr>
			<td class="reportsubheader" width="200">Scan date:</td>
			 <xsl:choose>
			  <xsl:when test="@LDate">
				<td><xsl:value-of select="@LDate"/>
				<xsl:value-of select="$ReportAgePH"/></td>
			  </xsl:when>
			  <xsl:otherwise>
				<td><xsl:value-of select="@Date"/>
				<xsl:value-of select="$ReportAgePH"/></td>
			  </xsl:otherwise>
			</xsl:choose>
		</tr>
		<xsl:if test="@MbsaToolVersion">
			  <tr>
				<td class="reportsubheader" width="200">Scanned with MBSA version:</td>
				<td><xsl:value-of select="@MbsaToolVersion"/>
				</td>
			</tr>
		</xsl:if>
		<xsl:if test="not(@MbsaToolVersion)">
			  <tr>
				<td class="reportsubheader" width="200">Scanned with MBSA version: </td>
				<td>1.0
				</td>
			</tr>
		</xsl:if>
		<xsl:if test="@HotfixDataVersion">
			  <tr>
				<td class="reportsubheader" width="200">Catalog synchronization date:</td>
				<td><xsl:value-of select="@HotfixDataVersion"/>
				<xsl:value-of select="$CatSyncAgePH"/>
				</td>
			</tr>
		</xsl:if>
		<xsl:if test="@WUSSource and @WUSSource != ''">
			  <tr>
				<td class="reportsubheader" width="200">Security update catalog:</td>
				<td><xsl:value-of select="@WUSSource"/>
				</td>
			</tr>
		</xsl:if>
		<xsl:if test="count(//AdditCabs/Cab) > 0">
			<xsl:for-each select="//AdditCabs/Cab">
			<tr>
				<td class="reportsubheader" width="200"></td>
				<td><xsl:value-of select="@Prop"/></td>
			</tr>
		</xsl:for-each>
		</xsl:if>
		<xsl:for-each select="//Check[@DataVersionName and @DataVersion]">
			<tr>
				<td class="reportsubheader" width="200"><xsl:value-of select="@DataVersionName"/></td>
				<td><xsl:value-of select="@DataVersion"/></td>
			</tr>
		</xsl:for-each>
	</table>
	<HR/>
</xsl:template>

</xsl:stylesheet>
