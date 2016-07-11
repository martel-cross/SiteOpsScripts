<?xml version="1.0"?> 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:variable name="ScoreLookup">
	  <c score="0" url="././././Graphics/dash.gif" alttext.loc="printreport.text.1" alttext="Check Not Performed"/>
	  <c score="1" url="././././Graphics/excl_red16.gif" alttext.loc="printreport.text.2" alttext="Unable to scan"/>
	  <c score="2" url="././././Graphics/mini_x_red.gif" alttext.loc="printreport.text.3" alttext="Check failed (critical)"/>
	  <c score="3" url="././././Graphics/mini_x_gold.gif" alttext.loc="printreport.text.4" alttext="Check failed (non-critical)"/>
	  <c score="4" url="././././Graphics/info.gif" alttext.loc="printreport.text.5" alttext="Best practice"/>
	  <c score="5" url="././././Graphics/mini_chek_grn.gif" alttext.loc="printreport.text.6" alttext="Check passed"/>
	  <c score="6" url="././././Graphics/dash.gif" alttext.loc="printreport.text.7" alttext="Check not performed"/>
	  <c score="7" url="././././Graphics/info.gif" alttext.loc="printreport.text.8" alttext="Additional information"/>
	  <c score="8" url="././././Graphics/mini_star_blu.gif" alttext.loc="printreport.text.9" alttext="Not approved"/>
	</xsl:variable>
  
  <xsl:variable name="ScoreLookupHeader">
    <c score="0" url="././././Graphics/dash.gif" alttext.loc="printreport.text.1" alttext="Check Not Performed"/>
    <c score="1" url="././././Graphics/excl_red.gif" alttext.loc="printreport.text.2" alttext="Unable to scan"/>
    <c score="2" url="././././Graphics/x_red.gif" alttext.loc="printreport.text.3" alttext="Check failed (critical)"/>
    <c score="3" url="././././Graphics/x_gold.gif" alttext.loc="printreport.text.4" alttext="Check failed (non-critical)"/>
    <c score="4" url="././././Graphics/blueinfo32.gif" alttext.loc="printreport.text.5" alttext="Best practice"/>
    <c score="5" url="././././Graphics/chek_grn.gif" alttext.loc="printreport.text.6" alttext="Check passed"/>
    <c score="6" url="././././Graphics/dash.gif" alttext.loc="printreport.text.7" alttext="Check not performed"/>
    <c score="7" url="././././Graphics/blueinfo32.gif" alttext.loc="printreport.text.8" alttext="Additional information"/>
    <c score="8" url="././././Graphics/star_blu.gif" alttext.loc="printreport.text.9" alttext="Not approved"/>
  </xsl:variable>

  <xsl:variable name="Assessment">
	  <c score="1" text.loc="printreport.texta.1" text="Incomplete Scan" longtext.loc="printreport.longtext.1" longtext="Could not complete one or more requested checks."/>
	  <c score="2" text.loc="printreport.texta.2" text="Severe Risk" longtext.loc="printreport.longtext.2" longtext="One or more critical checks failed."/>
	  <c score="3" text.loc="printreport.texta.3" text="Potential Risk" longtext.loc="printreport.longtext.3" longtext="One or more non-critical checks failed."/>
	  <c score="4" text.loc="printreport.texta.4" text="Security FYIs" longtext.loc="printreport.longtext.4" longtext=""/>
	  <c score="5" text.loc="printreport.texta.5" text="Strong Security" longtext.loc="printreport.longtext.5" longtext="The selected checks were passed."/>
	  <c score="8" text.loc="printreport.texta.4" text="Security FYIs" longtext.loc="printreport.longtext.4" longtext=""/>
	</xsl:variable>

	<xsl:variable name="SeverityLookup">
		<c value="4" text.loc="reportdetail2.sev.4" text="Critical"/>
		<c value="3" text.loc="reportdetail2.sev.3" text="Important"/>
		<c value="2" text.loc="reportdetail2.sev.2" text="Moderate"/>
		<c value="1" text.loc="reportdetail2.sev.1" text="Low"/>
		<c value="0" text.loc="reportdetail2.sev.0" text=""/>
	</xsl:variable>

	<xsl:variable name="FileName">FileNameHere</xsl:variable>
	
		<xsl:template match="SecScan">
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
      <table>
      <tr>  
      <td class="reportsubheader" width="140">Computer name:</td>
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
				<td class="reportsubheader" width="140">IP address:</td>
				<td><xsl:value-of select="@IP"/></td>
			</tr>
			<tr>
				<td class="reportsubheader" width="140">Security report name:</td>
				<td><xsl:value-of select="$FileName" /></td>
			</tr>
			<xsl:if test="@SUSServer and @SUSServer != ''">
				<tr>
					<td class="reportsubheader" width="140">Update Services server:</td>
					<td><xsl:value-of select="@SUSServer" /></td>
				</tr>
			</xsl:if>
			<tr>
				<td class="reportsubheader" width="140">Scan date:</td>
				<td><xsl:value-of select="@LDate"/></td>
			</tr>
			<xsl:choose>
			<xsl:when test="@HotfixDataVersion">
				  <tr>
					<td class="reportsubheader" width="140">Catalog synchronization date:</td>
					<td><xsl:value-of select="@HotfixDataVersion"/>
					</td>
				</tr>
			</xsl:when>
			</xsl:choose>	
			<xsl:choose>
			<xsl:when test="@WUSSource and @WUSSource != ''">
				  <tr>
					<td class="reportsubheader" width="140">Security update catalog:</td>
					<td><xsl:value-of select="@WUSSource"/>
					</td>
				</tr>
			</xsl:when>
			</xsl:choose>

			<xsl:choose>
			<xsl:when test="count(//AdditCabs/Cab) > 0">
				<xsl:for-each select="//AdditCabs/Cab">
					<tr>
						<td class="reportsubheader" width="140"></td>
						<td><xsl:value-of select="@Prop"/></td>
					</tr>
				</xsl:for-each>
			</xsl:when>
			</xsl:choose>

			<xsl:for-each select="//Check[@DataVersionName and @DataVersion]">
				  <tr>
					<td class="reportsubheader" width="140"><xsl:value-of select="@DataVersionName"/></td>
					<td><xsl:value-of select="@DataVersion"/></td>
				</tr>
			</xsl:for-each>
			</table>
			
			
			<xsl:choose>
			<xsl:when test="Check[@Type='5']">
				<br />
				<div class="reportheader">Security Updates</div>
				<xsl:choose>
				<xsl:when test="Check[@Type='5'][@Cat='1']">
					<br />
					<table width="100%" style="MARGIN-BOTTOM: 20px;" border="0" cellpadding="0" cellspacing="0">
						<tr class="ReportListHeader">
							<td style="width:40" align="center"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
							<td style="width:80" align="left"><nobr>Issue</nobr></td>
							<td><nobr>Result</nobr></td>
						</tr>
						<xsl:for-each select=".">
							<xsl:apply-templates select="Check[@ID='500' and @Type='5'][@Cat='1']" mode="wus">
								<xsl:sort order="sortorder" select="sortfield"/>
								<xsl:sort select="@Rank"/>
							</xsl:apply-templates>
							<xsl:apply-templates select="Check[@ID!='500' and @Type='5'][@Cat='1']">
								<xsl:sort order="sortorder" select="sortfield"/>
								<xsl:sort select="@Rank"/>
							</xsl:apply-templates>
						</xsl:for-each>
					</table>			
				</xsl:when>
				</xsl:choose>
			</xsl:when>
			</xsl:choose>
			
			
			<xsl:choose>
			<xsl:when test="Check[@Type='1']">
				<br />
				<div class="reportheader">Windows Scan Results</div>
				<xsl:choose>
				<xsl:when test="Check[@Type='1'][@Cat='1']">
					<br />
					<div class="reportsubheader" style="MARGIN-LEFT: 5px;">Administrative Vulnerabilities</div>
					<br />
					<table width="100%" style="MARGIN-BOTTOM: 20px;" border="0" cellpadding="0" cellspacing="0">
						<tr class="ReportListHeader">
							<td style="width:40" align="center"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
							<td style="width:80" align="left"><nobr>Issue</nobr></td>
							<td><nobr>Result</nobr></td>
						</tr>
						<xsl:for-each select=".">
							<xsl:apply-templates select="Check[@Type='1'][@Cat='1']">
								<xsl:sort order="sortorder" select="sortfield"/>
							</xsl:apply-templates>
						</xsl:for-each>
					</table>			
				</xsl:when>
				</xsl:choose>
				<xsl:choose>
				<xsl:when test="Check[@Type='1'][@Cat='2']">
					<br />
					<div class="reportsubheader" style="MARGIN-LEFT: 5px;">Additional System Information</div>
					<br />
					<table width="100%" style="MARGIN-BOTTOM: 20px" border="0" cellpadding="0" cellspacing="0">
						<tr class="ReportListHeader">
							<td style="width:40" align="center"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
							<td style="width:80" align="left"><nobr>Issue</nobr></td>
							<td><nobr>Result</nobr></td>
						</tr>
						<xsl:for-each select=".">
							<xsl:apply-templates select="Check[@Type='1'][@Cat='2']">
								<xsl:sort order="sortorder" select="sortfield"/>
							</xsl:apply-templates>
						</xsl:for-each>
					</table>
				</xsl:when>
				</xsl:choose>
			</xsl:when>
			</xsl:choose>

			<xsl:choose>
			<xsl:when test="Check[@Type='3']">	
				<br />
				<div class="reportheader">Internet Information Services (IIS) Scan Results</div>
				<xsl:choose>
				<xsl:when test="Check[@Type='3'][@Cat='1']">
					<br />
					<div class="reportsubheader" style="MARGIN-LEFT: 5px;">Administrative Vulnerabilities</div>
					<br />
					<table width="100%" style="MARGIN-BOTTOM: 20px" border="0" cellpadding="0" cellspacing="0">
						<tr class="ReportListHeader">
							<td style="width:40" align="center"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
							<td style="width:80" align="left"><nobr>Issue</nobr></td>
							<td><nobr>Result</nobr></td>
						</tr>
						<xsl:for-each select=".">
							<xsl:apply-templates select="Check[@Type='3'][@Cat='1']">
								<xsl:sort order="sortorder" select="sortfield"/>
							</xsl:apply-templates>
						</xsl:for-each>
					</table>			
				</xsl:when>
				</xsl:choose>
				<xsl:choose>
				<xsl:when test="Check[@Type='3'][@Cat='2']">
					<br />
					<div class="reportsubheader" style="MARGIN-LEFT: 5px;">Additional System Information</div>
					<br />
					<table width="100%" style="MARGIN-BOTTOM: 20px" border="0" cellpadding="0" cellspacing="0">
						<tr class="ReportListHeader">
							<td style="width:40" align="center"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
							<td style="width:80" align="left"><nobr>Issue</nobr></td>
							<td><nobr>Result</nobr></td>
						</tr>
						<xsl:for-each select=".">
							<xsl:apply-templates select="Check[@Type='3'][@Cat='2']">
								<xsl:sort order="sortorder" select="sortfield"/>
							</xsl:apply-templates>
						</xsl:for-each>
					</table>
				</xsl:when>
				</xsl:choose>
				<xsl:choose>
				<xsl:when test="Check[@Type='3'][@Cat='4']">
					<table width="100%" style="MARGIN-BOTTOM: 20px" border="0" cellpadding="0" cellspacing="0">
						<tr class="ReportListHeader">
							<td style="width:40" align="center"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
							<td style="width:80" align="left"><nobr>Issue</nobr></td>
							<td><nobr>Result</nobr></td>
						</tr>
						<xsl:for-each select=".">
							<xsl:apply-templates select="Check[@Type='3'][@Cat='4']">
								<xsl:sort order="sortorder" select="sortfield"/>
							</xsl:apply-templates>
						</xsl:for-each>
					</table>
				</xsl:when>
				</xsl:choose>
			</xsl:when>
			</xsl:choose>
			

			<!-- One tag per SQL Instance, MBSA V1.1 and later -->
			<xsl:choose>
				<xsl:when test="SQLInstance">
					<xsl:for-each select=".">
						<xsl:apply-templates select="SQLInstance"/>
					</xsl:for-each>
				</xsl:when>
			</xsl:choose>

			<xsl:choose>
			<xsl:when test="Check[@Type='2']">	
				<br />
				<div class="reportheader">SQL Server Scan Results</div>
				<xsl:choose>
				<xsl:when test="Check[@Type='2'][@Cat='1']">
					<br />
					<div class="reportsubheader" style="MARGIN-LEFT: 5px;">Administrative Vulnerabilities</div>
					<br />
					<table width="100%" style="MARGIN-BOTTOM: 20px" border="0" cellpadding="0" cellspacing="0">
						<tr class="ReportListHeader">
							<td style="width:40" align="center"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
							<td style="width:80" align="left"><nobr>Issue</nobr></td>
							<td><nobr>Result</nobr></td>
						</tr>
						<xsl:for-each select=".">
							<xsl:apply-templates select="Check[@Type='2'][@Cat='1']">
								<xsl:sort order="sortorder" select="sortfield"/>
							</xsl:apply-templates>
						</xsl:for-each>
					</table>			
				</xsl:when>
				</xsl:choose>
				<xsl:choose>
				<xsl:when test="Check[@Type='2'][@Cat='2']">
					<br />
					<div class="reportsubheader" style="MARGIN-LEFT: 5px;">Additional System Information</div>
					<br />
					<table width="100%" style="MARGIN-BOTTOM: 20px" border="0" cellpadding="0" cellspacing="0">
						<tr class="ReportListHeader">
							<td style="width:40" align="center"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
							<td style="width:80" align="left"><nobr>Issue</nobr></td>
							<td><nobr>Result</nobr></td>
						</tr>
						<xsl:for-each select=".">
							<xsl:apply-templates select="Check[@Type='2'][@Cat='2']">
								<xsl:sort order="sortorder" select="sortfield"/>
							</xsl:apply-templates>
						</xsl:for-each>
					</table>
				</xsl:when>
				</xsl:choose>
				<xsl:choose>
				<xsl:when test="Check[@Type='2'][@Cat='4']">
					<table width="100%" style="MARGIN-BOTTOM: 20px" border="0" cellpadding="0" cellspacing="0">
						<tr class="ReportListHeader">
							<td style="width:40" align="center"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
							<td style="width:80" align="left"><nobr>Issue</nobr></td>
							<td><nobr>Result</nobr></td>
						</tr>
						<xsl:for-each select=".">
							<xsl:apply-templates select="Check[@Type='2'][@Cat='4']">
								<xsl:sort order="sortorder" select="sortfield"/>
							</xsl:apply-templates>
						</xsl:for-each>
					</table>
				</xsl:when>
				</xsl:choose>
			</xsl:when>
			</xsl:choose>
			
			<xsl:choose>
			<xsl:when test="Check[@Type='4']">	
				<br />
				<div class="reportheader">Desktop Application Scan Results</div>
				<xsl:choose>
				<xsl:when test="Check[@Type='4'][@Cat='1']">
					<br />
					<div class="reportsubheader" style="MARGIN-LEFT: 5px;">Administrative Vulnerabilities</div>
					<br />
					<table width="100%" style="MARGIN-BOTTOM: 20px" border="0" cellpadding="0" cellspacing="0">
						<tr class="ReportListHeader">
							<td style="width:40" align="center"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
							<td style="width:80" align="left"><nobr>Issue</nobr></td>
							<td><nobr>Result</nobr></td>
						</tr>
						<xsl:for-each select=".">
							<xsl:apply-templates select="Check[@Type='4'][@Cat='1']">
								<xsl:sort order="sortorder" select="sortfield"/>
							</xsl:apply-templates>
						</xsl:for-each>
					</table>			
				</xsl:when>
				</xsl:choose>
				<xsl:choose>
				<xsl:when test="Check[@Type='4'][@Cat='2']">
					<br />
					<div class="reportsubheader" style="MARGIN-LEFT: 5px;">Additional System Information</div>
					<br />
					<table width="100%" style="MARGIN-BOTTOM: 20px" border="0" cellpadding="0" cellspacing="0">
						<tr class="ReportListHeader">
							<td style="width:40" align="center"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
							<td style="width:80" align="left"><nobr>Issue</nobr></td>
							<td><nobr>Result</nobr></td>
						</tr>
						<xsl:for-each select=".">
							<xsl:apply-templates select="Check[@Type='4'][@Cat='2']">
								<xsl:sort order="sortorder" select="sortfield"/>
							</xsl:apply-templates>
						</xsl:for-each>
					</table>
				</xsl:when>
				</xsl:choose>
			</xsl:when>
			</xsl:choose>
			
		</xsl:template>
	
	<xsl:template match="Check">
		<xsl:param name="score" select="@Grade"/>
		
			<xsl:variable name="bgcolor">
			<xsl:choose>
				<xsl:when test="(position() mod 2) = 1">#8caae6</xsl:when>
				<xsl:otherwise>#CECFF6</xsl:otherwise>
			</xsl:choose>
			</xsl:variable>
			<tr bgcolor="{$bgcolor}">
				<td align="center" valign="top" style="padding-bottom: 10px;">
					<xsl:choose>
					  <xsl:when test="@Cat='2'">
						<xsl:choose>
						  <xsl:when test="@ID='121'">
							<img alt="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=7]/@alttext}" src="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=7]/@url}" />
					 	  </xsl:when>
						  <xsl:when test="@ID='10121'">
							<img alt="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=7]/@alttext}" src="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=7]/@url}" />
					 	  </xsl:when>
						  <xsl:when test="@ID='101'">
							<img alt="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=$score]/@alttext}" src="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=$score]/@url}" />
					 	  </xsl:when>
						  <xsl:when test="@ID='10101'">
							<img alt="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=7]/@alttext}" src="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=7]/@url}" />
					 	  </xsl:when>
						  <xsl:otherwise>
						    <img alt="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=4]/@alttext}" src="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=4]/@url}" />
						  </xsl:otherwise>
						</xsl:choose>
					  </xsl:when>
					  <xsl:otherwise>
						<img alt="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=$score]/@alttext}" src="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=$score]/@url}" />	
					  </xsl:otherwise>
					</xsl:choose>	
				</td>
				<td width="75" style="padding-bottom: 10px;"><xsl:value-of select="@Name"/></td>
				<td style="padding-bottom: 10px;"> 
					<TABLE width="100%">  
					  <TR>
					    <TD align="left" colspan="3"><xsl:value-of select="Advice"/></TD>
					  </TR>
						<xsl:choose>
						  <xsl:when test="Detail">
							<TR>
							<TD>
							<table width="100%" border="0" cellpadding="0" cellspacing="0" style="padding-left: 10px; padding-right: 10px;">
								<tr class="ReportListHeader">
									<xsl:for-each select="Detail/Head/Col">
										<td Nowrap="true">
										<xsl:value-of select="."/>&#160;&#160;
										</td>
									</xsl:for-each>
								</tr>
								<xsl:for-each select="Detail">
									<xsl:apply-templates select="Row">
									</xsl:apply-templates>
								</xsl:for-each>
							</table>
							</TD>
							</TR>
						  </xsl:when>
						</xsl:choose>	
					</TABLE>
					<br/>
				</td>
			</tr>
	</xsl:template>
	
	<xsl:template match="Row">
		<xsl:param name="score" select="@Grade"/>
			<tr>
				<xsl:for-each select="Col">
				<td valign="top" style="padding-bottom: 5px;">
				 <xsl:choose>
				  <xsl:when test="@URL and @URL != '' and @URL != ' '">
					<A href="{@URL}"><xsl:value-of select="."/></A>
				  </xsl:when>
				  <xsl:otherwise>
					<xsl:value-of select="."/>
				  </xsl:otherwise>
				</xsl:choose>	

				<xsl:if test="@REQUIREDNAME">
					<br/><div class="halignlikea">This update requires
					<!-- argstart reportcolumn.mustinst.requiredpatchname --><xsl:value-of select="@REQUIREDNAME"/><!-- argend -->
					to be installed first.</div>
				</xsl:if>

				</td>
				</xsl:for-each>
			</tr>
			<xsl:apply-templates select="SETTINGS">
			</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="SETTINGS">
		<xsl:param name="numCols" select="count(Head/Col)"/>
			<tr>
				<td colspan="4">
					<table width="100%" border="0" cellpadding="0" cellspacing="0" style="padding-left: 10px; padding-right: 10px;">
						<tr class="ReportListHeader">
							<xsl:for-each select="Head/Col">
								<td Nowrap="true">
									<B><xsl:value-of select="."/></B>
								</td>
							</xsl:for-each>
						</tr>
						<xsl:apply-templates select="Row">
						</xsl:apply-templates>
					</table>
				</td>
			</tr>
	</xsl:template>


	<!-- SQL Instance section -->
	<xsl:template match="SQLInstance">
		<br />
		<div class="reportheader">SQL Server Scan Results: Instance <!--argstart instance--><xsl:value-of select="@Name"/><!--argend--></div>
		<xsl:choose>
		<xsl:when test="Check[@Type='2'][@Cat='1']">
			<br />
			<div class="reportsubheader" style="MARGIN-LEFT: 5px;">Administrative Vulnerabilities</div>
			<br />
			<table width="100%" style="MARGIN-BOTTOM: 20px" border="0" cellpadding="0" cellspacing="0">
				<tr class="ReportListHeader">
							<td style="width:40" align="center"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
							<td style="width:80" align="left"><nobr>Issue</nobr></td>
							<td><nobr>Result</nobr></td>
				</tr>
				<xsl:for-each select=".">
					<xsl:apply-templates select="Check[@Type='2'][@Cat='1']">
						<xsl:sort order="sortorder" select="sortfield"/>
					</xsl:apply-templates>
				</xsl:for-each>
			</table>			
		</xsl:when>
		</xsl:choose>
		<xsl:choose>
		<xsl:when test="Check[@Type='2'][@Cat='2']">
			<br />
			<div class="reportsubheader" style="MARGIN-LEFT: 5px;">Additional System Information</div>
			<br />
			<table width="100%" style="MARGIN-BOTTOM: 20px" border="0" cellpadding="0" cellspacing="0">
				<tr class="ReportListHeader">
							<td style="width:40" align="center"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
							<td style="width:80" align="left"><nobr>Issue</nobr></td>
							<td><nobr>Result</nobr></td>
				</tr>
				<xsl:for-each select=".">
					<xsl:apply-templates select="Check[@Type='2'][@Cat='2']">
						<xsl:sort order="sortorder" select="sortfield"/>
					</xsl:apply-templates>
				</xsl:for-each>
			</table>
		</xsl:when>
		</xsl:choose>
		<xsl:choose>
		<xsl:when test="Check[@Type='2'][@Cat='4']">
			<table width="100%" style="MARGIN-BOTTOM: 20px" border="0" cellpadding="0" cellspacing="0">
				<tr class="ReportListHeader">
							<td style="width:40" align="center"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
							<td style="width:80" align="left"><nobr>Issue</nobr></td>
							<td><nobr>Result</nobr></td>
				</tr>
				<xsl:for-each select=".">
					<xsl:apply-templates select="Check[@Type='2'][@Cat='4']">
						<xsl:sort order="sortorder" select="sortfield"/>
					</xsl:apply-templates>
				</xsl:for-each>
			</table>
		</xsl:when>
		</xsl:choose>
	</xsl:template>
			
	<xsl:template match="Check" mode="wus">
			<xsl:param name="score" select="@Grade"/>
			<xsl:variable name="bgcolor">
			<xsl:choose>
				<xsl:when test="(position() mod 2) = 1">#8caae6</xsl:when>
				<xsl:otherwise>#CECFF6</xsl:otherwise>
			</xsl:choose>
			</xsl:variable>
			<tr bgcolor="{$bgcolor}">
				<td align="center" valign="top" style="padding-bottom: 10px;">
					<img alt="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=$score]/@alttext}" src="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=$score]/@url}" />	
				</td>
				<td style="WIDTH:75" align="left" valign="top"><xsl:value-of select="@Name"/></td>
				<td> 
					<TABLE width="100%">  
					  <TR>
					    <TD align="left" colspan="3"><xsl:value-of select="Advice"/></TD>
					  </TR>
						<xsl:choose>
						  <xsl:when test="Detail">
							<TR>
							<TD>
								<xsl:apply-templates select="." mode="wus2"/>
							</TD>
							</TR>
						  </xsl:when>
						</xsl:choose>	
					</TABLE>
				</td>
			</tr>
	</xsl:template>

	<xsl:template match="Check" mode="wus2">
			<table id="TableID" width="100%" border="0" cellpadding="0" cellspacing="5" class="DetailsTable">
	
				<!-- 1st section: Missing critical updates -->
				<xsl:if test="count(Detail/UpdateData[(@IsInstalled='false' or @RestartRequired='true') and @Type=1]) > 0">
					<tr><td colspan="5" class="tdText">
						<b>Security Updates</b>
					</td></tr>
									
					<tr >
						<td class="DetailHeader" width="32">Score</td>
						<td class="DetailHeader" width="32">ID</td>
						<td class="DetailHeader" width="100%">Description</td>
						<td class="DetailHeader" width="32">Maximum Severity</td>
					</tr>
						
					<xsl:apply-templates select="Detail/UpdateData[(@IsInstalled='false' or @RestartRequired='true') and @Type=1]" mode="missing"/>
				</xsl:if>
				
				<!-- 2nd section: Missing rollups and service packs -->
				<xsl:if test="count(Detail/UpdateData[(@IsInstalled='false' or @RestartRequired='true') and @Type!=1]) > 0">
					<tr><td colspan="5" class="tdText">
						<b>Update Rollups and Service Packs</b>
					</td></tr>
									
					<tr>
						<td class="DetailHeader" width="32">Score</td>
						<td class="DetailHeader" width="32">ID</td>
						<td class="DetailHeader" width="100%" colspan="2">Description</td>
					</tr>
						
					<xsl:apply-templates select="Detail/UpdateData[(@IsInstalled='false' or @RestartRequired='true') and @Type!=1]" mode="missing"/>
				</xsl:if>

				<!-- 3rd section: Installed items -->
				<xsl:if test="count(Detail/UpdateData[@IsInstalled='true' and (not(@RestartRequired) or @RestartRequired='false')]) > 0">
					<tr><td colspan="5" class="tdText">
						<b>Current Update Compliance</b>
					</td></tr>
									
					<tr>
						<td class="DetailHeader" width="32">Score</td>
						<td class="DetailHeader" width="32">ID</td>
						<td class="DetailHeader" width="100%">Description</td>
						<td class="DetailHeader" width="32">Maximum Severity</td>
						<td class="DetailHeader">&#160;</td>
					</tr>
						
					<xsl:apply-templates select="Detail/UpdateData[@IsInstalled='true' and (not(@RestartRequired) or @RestartRequired='false')]" mode="installed"/>
				</xsl:if>
			</table>
	</xsl:template>
	
	<xsl:template match="UpdateData" mode="installed">
	<xsl:variable name="GradeText">
		<xsl:choose>
			<xsl:when test="@IsInstalled='true'">Installed</xsl:when>
			<xsl:when test="@IsInstalled='false' and not(@WUSApproved)">Missing</xsl:when>
			<xsl:when test="@IsInstalled='false' and @WUSApproved='true'">Missing</xsl:when>
			<xsl:when test="@IsInstalled='false' and @WUSApproved='false'">Not Approved</xsl:when>
			<xsl:otherwise></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
		<tr>
			<td valign="top" align="left" nowrap="nowrap">
				<xsl:value-of select="$GradeText"/>
			</td>
			<td valign="top" nowrap="nowrap">
				<xsl:value-of select="@ID"/>
				<xsl:apply-templates select="References/OtherIDs"/>
			</td>
			<td valign="top">
				<xsl:value-of select="Title"/>
				<xsl:apply-templates select="@RestartRequired"/>
			</td>
			<td valign="top">
				<xsl:variable name="SevValue"><xsl:value-of select="@Severity"/></xsl:variable>
				<xsl:choose>
					<xsl:when test="$SevValue > 0">
						<xsl:value-of select="document('')/*/xsl:variable[@name='SeverityLookup']/c[@value=$SevValue]/@text"/>
					</xsl:when>
					<xsl:otherwise>&#160;</xsl:otherwise>
				</xsl:choose>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="UpdateData" mode="missing">
	<xsl:variable name="GradeText">
		<xsl:choose>
			<xsl:when test="@IsInstalled='true'">Installed</xsl:when>
			<xsl:when test="@IsInstalled='false' and not(@WUSApproved)">Missing</xsl:when>
			<xsl:when test="@IsInstalled='false' and @WUSApproved='true'">Missing</xsl:when>
			<xsl:when test="@IsInstalled='false' and @WUSApproved='false'">Not Approved</xsl:when>
			<xsl:otherwise></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
		<xsl:variable name="grade">
			<xsl:choose>
				<xsl:when test="@WUSApproved and @WUSApproved = 'false'">8</xsl:when>
				<xsl:when test="@Type != 1">3</xsl:when>
				<xsl:otherwise>2</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<tr>
			<td valign="top" align="left" nowrap="nowrap">
				<xsl:value-of select="$GradeText"/>
			</td>
			<td valign="top" nowrap="nowrap">
				<xsl:value-of select="@ID"/>
				<xsl:apply-templates select="References/OtherIDs"/>
			</td>
			<xsl:choose>
				<xsl:when test="@Type = 1">
					<td valign="top">
						<xsl:value-of select="Title"/>
						<xsl:apply-templates select="@RestartRequired"/>
					</td>
					<td valign="top">
						<xsl:variable name="SevValue"><xsl:value-of select="@Severity"/></xsl:variable>
						<xsl:choose>
							<xsl:when test="$SevValue > 0">
								<xsl:value-of select="document('')/*/xsl:variable[@name='SeverityLookup']/c[@value=$SevValue]/@text"/>
							</xsl:when>
							<xsl:otherwise>&#160;</xsl:otherwise>
						</xsl:choose>
					</td>
				</xsl:when>
				<xsl:otherwise>
					<td valign="top" colspan="2">
						<xsl:value-of select="Title"/>
						<xsl:apply-templates select="@RestartRequired"/>
					</td>
				</xsl:otherwise>
			</xsl:choose>
		</tr>
	</xsl:template>	

	<xsl:template match="@RestartRequired">
		<xsl:if test=".='true'">
			<br/>
			<br/>
			<font color="gray">Installation of this software update was not completed. You must restart your computer to finish the installation.</font>
		</xsl:if>
	</xsl:template>

	<xsl:template match="OtherIDs">
		<br/>
		<xsl:apply-templates select="OtherID"/>
	</xsl:template>
	
	<xsl:template match="OtherID">
		<xsl:value-of select="."/><br/>
	</xsl:template>
	
</xsl:stylesheet>
