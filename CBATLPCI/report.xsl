<?xml version="1.0"?> 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:variable name="ScoreLookup">
	  <c score="0" url="Graphics/dash.gif" alttext.loc="report.text.1" alttext="Check Not Performed"/>
	  <c score="1" url="Graphics/excl_red16.gif" alttext.loc="report.text.2" alttext="Unable to scan"/>
	  <c score="2" url="Graphics/mini_x_red.gif" alttext.loc="report.text.3" alttext="Check failed (critical)"/>
	  <c score="3" url="Graphics/mini_x_gold.gif" alttext.loc="report.text.4" alttext="Check failed (non-critical)"/>
	  <c score="4" url="Graphics/info.gif" alttext.loc="report.text.5" alttext="Best practice"/>
	  <c score="5" url="Graphics/mini_chek_grn.gif" alttext.loc="report.text.6" alttext="Check passed"/>
	  <c score="6" url="Graphics/dash.gif" alttext.loc="report.text.7" alttext="Check not performed"/>
	  <c score="7" url="Graphics/info.gif" alttext.loc="report.text.8" alttext="Additional information"/>
	  <c score="8" url="Graphics/mini_star_blu.gif" alttext.loc="report.text.9" alttext="Not approved"/>
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
			
		<!-- Security Update (hotfix) section -->
		<xsl:choose>
		<xsl:when test="Check[@Type='5']">
			<br />
			<div class="reportheader">Security Update Scan Results</div>
			<br />
			<xsl:choose>
			<xsl:when test="Check[@Type='5'][@Cat='1']">
				<table width="100%" border="0" cellpadding="4" cellspacing="0">
					<tr class="ReportListHeader">
						<td class="ReportListHeader" style="width:40;padding-left:10" valign="middle"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
						<td class="ReportListHeader" style="width:80;padding-left:10" valign="middle"><nobr>Issue&#160;</nobr></td>
						<td class="ReportListHeader" style="padding-left:10" valign="middle"><nobr>Result&#160;</nobr></td>
					</tr>
					<xsl:for-each select=".">
						<xsl:apply-templates select="Check[@Type='5'][@Cat='1']">
							<xsl:sort order="sortorder" select="sortfield"/>
							<xsl:sort order="sortorder" select="@Rank"/>
						</xsl:apply-templates>
					</xsl:for-each>
				</table>			
			</xsl:when>
			</xsl:choose>
		</xsl:when>
		</xsl:choose>
		
		
		<!-- Windows (OS) section -->
		<xsl:choose>
		<xsl:when test="Check[@Type='1']">
			<br />
			<div class="reportheader">Windows Scan Results</div>
			<xsl:choose>
			<xsl:when test="Check[@Type='1'][@Cat='1']">
				<br />
				<div class="reportsubheader" style="MARGIN-LEFT: 5px;">Administrative Vulnerabilities</div>
				<br />
				<table width="100%" border="0" cellpadding="4" cellspacing="0">
					<tr class="ReportListHeader">
						<td class="ReportListHeader" style="width:40;padding-left:10"  valign="middle"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
						<td class="ReportListHeader" style="width:80;padding-left:10" valign="middle"><nobr>Issue&#160;</nobr></td>
						<td class="ReportListHeader" style="padding-left:10" valign="middle"><nobr>Result&#160;</nobr></td>
					</tr>
					<xsl:for-each select=".">
						<xsl:apply-templates select="Check[@Type='1'][@Cat='1']">
							<xsl:sort order="sortorder" select="sortfield"/>
							<xsl:sort order="sortorder" select="@Rank"/>
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
				<table width="100%" border="0" cellpadding="4" cellspacing="0">
					<tr class="ReportListHeader">
						<td class="ReportListHeader" style="width:40;padding-left:10" valign="middle"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
						<td class="ReportListHeader" style="width:80;padding-left:10" valign="middle"><nobr>Issue&#160;</nobr></td>
						<td class="ReportListHeader" style="padding-left:10" valign="middle"><nobr>Result&#160;</nobr></td>
					</tr>
					<xsl:for-each select=".">
						<xsl:apply-templates select="Check[@Type='1'][@Cat='2']">
							<xsl:sort order="sortorder" select="@Rank"/>
						</xsl:apply-templates>
					</xsl:for-each>
				</table>
			</xsl:when>
			</xsl:choose>
		</xsl:when>
		</xsl:choose>

		<!-- IIS section -->
		<xsl:choose>
		<xsl:when test="Check[@Type='3']">	
			<br />
			<div class="reportheader">Internet Information Services (IIS) Scan Results</div>
			<xsl:choose>
			<xsl:when test="Check[@Type='3'][@Cat='1']">
				<br />
				<div class="reportsubheader" style="MARGIN-LEFT: 5px;">Administrative Vulnerabilities</div>
				<br />
				<table width="100%" border="0" cellpadding="4" cellspacing="0">
					<tr class="ReportListHeader">
						<td class="ReportListHeader" style="width:40;padding-left:10" valign="middle"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
						<td class="ReportListHeader" style="width:80;padding-left:10" valign="middle"><nobr>Issue&#160;</nobr></td>
						<td class="ReportListHeader" style="padding-left:10" valign="middle"><nobr>Result&#160;</nobr></td>
					</tr>
					<xsl:for-each select=".">
						<xsl:apply-templates select="Check[@Type='3'][@Cat='1']">
							<xsl:sort order="sortorder" select="sortfield"/>
							<xsl:sort order="sortorder" select="@Rank"/>
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
				<table width="100%" border="0" cellpadding="4" cellspacing="0">
					<tr class="ReportListHeader">
						<td class="ReportListHeader" style="width:40;padding-left:10" valign="middle"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
						<td class="ReportListHeader" style="width:80;padding-left:10" valign="middle"><nobr>Issue&#160;</nobr></td>
						<td class="ReportListHeader" style="padding-left:10" valign="middle"><nobr>Result&#160;</nobr></td>
					</tr>
					<xsl:for-each select=".">
						<xsl:apply-templates select="Check[@Type='3'][@Cat='2']">
							<xsl:sort order="sortorder" select="sortfield"/>
							<xsl:sort order="sortorder" select="@Rank"/>
						</xsl:apply-templates>
					</xsl:for-each>
				</table>
			</xsl:when>
			</xsl:choose>
		</xsl:when>
		</xsl:choose>
		<xsl:choose>

		<!-- IIS Not Installed section -->
		<xsl:when test="Check[@Type='3'][@Cat='4']">
			<br />
			<table width="100%" border="0" cellpadding="4" cellspacing="0">
					<tr class="ReportListHeader">
						<td class="ReportListHeader" style="width:40;padding-left:10" valign="middle"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
						<td class="ReportListHeader" style="width:80;padding-left:10" valign="middle"><nobr>Issue&#160;</nobr></td>
						<td class="ReportListHeader" style="padding-left:10" valign="middle"><nobr>Result&#160;</nobr></td>
					</tr>
				<xsl:for-each select=".">
					<xsl:apply-templates select="Check[@Type='3'][@Cat='4']">
						<xsl:sort order="sortorder" select="sortfield"/>
						<xsl:sort order="sortorder" select="@Rank"/>
					</xsl:apply-templates>
				</xsl:for-each>
			</table>
		</xsl:when>
		</xsl:choose>
			

		<!-- One tag per SQL Instance, MBSA V1.1 and later -->
		<xsl:choose>
			<xsl:when test="SQLInstance">
			<br />
			<div class="reportheader">SQL Server Scan Results</div>
				<xsl:for-each select=".">
					<xsl:apply-templates select="SQLInstance"/>
				</xsl:for-each>
			</xsl:when>
		</xsl:choose>


		<!-- SQL Checks, all instances, MBSA V1.0 only -->
		<xsl:choose>
			<xsl:when test="Check[@Type='2']">	
				<br />
				<div class="reportheader">SQL Server Scan Results</div>
				<xsl:choose>
					<xsl:when test="Check[@Type='2'][@Cat='1']">
						<br />
						<div class="reportsubheader" style="MARGIN-LEFT: 5px;">Administrative Vulnerabilities</div>
						<br />
						<table width="100%" border="0" cellpadding="4" cellspacing="0">
							<tr class="ReportListHeader">
								<td class="ReportListHeader" style="width:40;padding-left:10" valign="middle"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
								<td class="ReportListHeader" style="width:80;padding-left:10" valign="middle"><nobr>Issue&#160;</nobr></td>
								<td class="ReportListHeader" style="padding-left:10" valign="middle"><nobr>Result&#160;</nobr></td>
							</tr>
							<xsl:for-each select=".">
								<xsl:apply-templates select="Check[@Type='2'][@Cat='1']">
									<xsl:sort order="sortorder" select="sortfield"/>
									<xsl:sort order="sortorder" select="@Rank"/>
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
						<table width="100%" border="0" cellpadding="4" cellspacing="0">
							<tr class="ReportListHeader">
								<td class="ReportListHeader" style="width:40;padding-left:10" valign="middle"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
								<td class="ReportListHeader" style="width:80;padding-left:10" valign="middle"><nobr>Issue&#160;</nobr></td>
								<td class="ReportListHeader"  style="padding-left:10" valign="middle"><nobr>Result&#160;</nobr></td>
							</tr>
							<xsl:for-each select=".">
								<xsl:apply-templates select="Check[@Type='2'][@Cat='2']">
									<xsl:sort order="sortorder" select="sortfield"/>
									<xsl:sort order="sortorder" select="@Rank"/>
								</xsl:apply-templates>
							</xsl:for-each>
						</table>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>


		<!-- SQL not installed -->
		<xsl:choose>
			<xsl:when test="Check[@Type='2'][@Cat='4']">
				<br />
				<table width="100%" border="0" cellpadding="4" cellspacing="0">
						<tr class="ReportListHeader">
							<td class="ReportListHeader" style="width:40;padding-left:10" valign="middle"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
							<td class="ReportListHeader" style="width:80;padding-left:10" valign="middle"><nobr>Issue&#160;</nobr></td>
							<td class="ReportListHeader" style="padding-left:10" valign="middle"><nobr>Result&#160;</nobr></td>
						</tr>
					<xsl:for-each select=".">
						<xsl:apply-templates select="Check[@Type='2'][@Cat='4']">
							<xsl:sort order="sortorder" select="sortfield"/>
							<xsl:sort order="sortorder" select="@Rank"/>
						</xsl:apply-templates>
					</xsl:for-each>
				</table>
			</xsl:when>
		</xsl:choose>
			
		<!-- Desktop Section -->
		<xsl:choose>
		<xsl:when test="Check[@Type='4']">	
			<br />
			<div class="reportheader">Desktop Application Scan Results</div>
			<xsl:choose>
			<xsl:when test="Check[@Type='4'][@Cat='1']">
				<br />
				<div class="reportsubheader" style="MARGIN-LEFT: 5px;">Administrative Vulnerabilities</div>
				<br />
				<table width="100%" border="0" cellpadding="4" cellspacing="0">
					<tr class="ReportListHeader">
						<td class="ReportListHeader" style="width:40;padding-left:10" valign="middle"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
						<td class="ReportListHeader" style="width:80;padding-left:10" valign="middle"><nobr>Issue&#160;</nobr></td>
						<td class="ReportListHeader" style="padding-left:10" valign="middle"><nobr>Result&#160;</nobr></td>
					</tr>
					<xsl:for-each select=".">
						<xsl:apply-templates select="Check[@Type='4'][@Cat='1']">
							<xsl:sort order="sortorder" select="sortfield"/>
							<xsl:sort order="sortorder" select="@Rank"/>
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
				<table width="100%" border="0" cellpadding="4" cellspacing="0">
					<tr class="ReportListHeader">
						<td class="ReportListHeader" style="width:40;padding-left:10" valign="middle"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
						<td class="ReportListHeader" style="width:80;padding-left:10" valign="middle"><nobr>Issue&#160;</nobr></td>
						<td class="ReportListHeader" style="padding-left:10" valign="middle"><nobr>Result&#160;</nobr></td>
					</tr>
					<xsl:for-each select=".">
						<xsl:apply-templates select="Check[@Type='4'][@Cat='2']">
							<xsl:sort order="sortorder" select="@Rank"/>
						</xsl:apply-templates>
					</xsl:for-each>
				</table>
			</xsl:when>
			</xsl:choose>
		</xsl:when>
		</xsl:choose>
	</xsl:template>
	

	<!-- SQL Instance section -->
	<xsl:template match="SQLInstance">
		<br />
		<div class="reportsubheader" style="MARGIN-LEFT: 2px;">Instance <!--argstart number--><xsl:value-of select="@Name"/><!--argend--> </div>
		<xsl:choose>
			<xsl:when test="Check[@Type='2'][@Cat='1']">
				<br />
				<div class="reportsubheader" style="MARGIN-LEFT: 5px;">Administrative Vulnerabilities</div>
				<br />
				<table width="100%" border="0" cellpadding="4" cellspacing="0">
					<tr class="ReportListHeader">
						<td class="ReportListHeader" style="width:40;padding-left:10" valign="middle"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
						<td class="ReportListHeader" style="width:80;padding-left:10" valign="middle"><nobr>Issue&#160;</nobr></td>
						<td class="ReportListHeader" style="padding-left:10" valign="middle"><nobr>Result&#160;</nobr></td>
					</tr>
					<xsl:for-each select=".">
						<xsl:apply-templates select="Check[@Type='2'][@Cat='1']">
							<xsl:sort order="sortorder" select="sortfield"/>
							<xsl:sort order="sortorder" select="@Rank"/>
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
				<table width="100%" border="0" cellpadding="4" cellspacing="0">
					<tr class="ReportListHeader">
						<td class="ReportListHeader" style="width:40;padding-left:10" valign="middle"><nobr>&#160;&#160;Score&#160;&#160;</nobr></td>
						<td class="ReportListHeader" style="width:80;padding-left:10" valign="middle"><nobr>Issue&#160;</nobr></td>
						<td class="ReportListHeader" style="padding-left:10" valign="middle"><nobr>Result&#160;</nobr></td>
					</tr>
					<xsl:for-each select=".">
						<xsl:apply-templates select="Check[@Type='2'][@Cat='2']">
							<xsl:sort order="sortorder" select="sortfield"/>
							<xsl:sort order="sortorder" select="@Rank"/>
						</xsl:apply-templates>
					</xsl:for-each>
				</table>
			</xsl:when>
		</xsl:choose>
	</xsl:template>



	<!-- For an individual Check -->
	<xsl:template match="Check">
		<xsl:param name="score" select="@Grade"/>
	
			<xsl:variable name="DetailURL">
			<xsl:choose>
				<!-- Handle IE Zones details  -->
				<xsl:when test="@ID=118">javascript:OpenDetails('<xsl:value-of select="@ID"/>',false,true, '', '')</xsl:when>
				<!-- Handle hotfix details -->
				<xsl:when test="@Type=5">
					<xsl:choose>
					<xsl:when test="@Instance">javascript:OpenDetails('<xsl:value-of select="@ID"/>',true,false, '<xsl:value-of select="@Instance"/>', '<xsl:value-of select="@GroupID"/>')</xsl:when>
					<xsl:otherwise>javascript:OpenDetails('<xsl:value-of select="@ID"/>',true,false, '', '<xsl:value-of select="@GroupID"/>')</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<!-- Handle SQL Instance details -->
				<xsl:when test="@Type=2">
					<xsl:choose>
					<xsl:when test="../../SQLInstance">javascript:OpenDetails('<xsl:value-of select="@ID"/>', false,false,'<xsl:value-of select="../@Name"/>', '')</xsl:when>
					<xsl:otherwise>javascript:OpenDetails('<xsl:value-of select="@ID"/>',false,false, '', '')</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<!-- Handle all other details -->
				<xsl:otherwise>javascript:OpenDetails('<xsl:value-of select="@ID"/>',false,false, '', '')</xsl:otherwise>
			</xsl:choose>
			</xsl:variable>		
		
			<xsl:variable name="classname">
			<xsl:choose>
				<xsl:when test="(position() mod 2) = 1">ReportsRowOverEven</xsl:when>
				<xsl:otherwise>ReportsRowOverOdd</xsl:otherwise>
			</xsl:choose>
			</xsl:variable>
			<tr class="{$classname}">
				<td align="center" valign="middle">
					<xsl:choose>
					  <xsl:when test="@Cat='2' and @Type!='6'">
						<xsl:choose>
						  <xsl:when test="@ID='121'">
							<img alt="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=7]/@alttext}" src="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=7]/@url}" />
					 	  </xsl:when>
						  <xsl:when test="@ID='10121'">
							<img alt="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=7]/@alttext}" src="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=7]/@url}" />
					 	  </xsl:when>
              <xsl:when test="@ID='123'">
              <img alt="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=7]/@alttext}" src="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=7]/@url}" />
              </xsl:when>
              <xsl:when test="@ID='10123'">
              <img alt="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=7]/@alttext}" src="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=7]/@url}" />
              </xsl:when>
              <xsl:when test="@ID='119'">
                <img alt="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=7]/@alttext}" src="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=7]/@url}" />
              </xsl:when>
              <xsl:when test="@ID='10119'">
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
					  <xsl:when test="(@ID='178' or @ID='10178' or @ID='20178') or 
							  (@ID='179' or @ID='10179' or @ID='20179') or
							  (@ID='228' or @ID='10228' or @ID='20228')">
						<xsl:choose>
						  <xsl:when test="@Grade='4'">
							<img alt="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=7]/@alttext}" src="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=7]/@url}" />
						  </xsl:when>
						  <xsl:otherwise>
							<img alt="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=$score]/@alttext}" src="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=$score]/@url}" />	
						  </xsl:otherwise>
						</xsl:choose>
					  </xsl:when>
					  <xsl:otherwise>
						<img alt="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=$score]/@alttext}" src="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=$score]/@url}" />	
					  </xsl:otherwise>
					</xsl:choose>	
				</td>
				<td style="width:75">
					<TABLE width="100%">  
					  <TR>
						<TD align="left"><xsl:value-of select="@Name"/></TD>
					  </TR>
					</TABLE>
				</td>
				<td> 
					<TABLE width="100%">  
					  <TR>
					    <TD align="left" colspan="3"><xsl:value-of select="Advice"/></TD>
					  </TR>
					  <TR>
					  <TD>
					  <nobr>
	
						<xsl:choose>
							<xsl:when test="$score=5 or $score=0 or $score=6 or ($score=1 and @ID &lt; 20000)">
								<xsl:choose>
								  <xsl:when test="@URL1 and @URL1 != '' and @URL1 != ' '">
									<A class="sys-link-normal" style="padding: 0 0 0 0" target="_blank" href="{@URL1}">What was scanned</A>					   
								  </xsl:when>
								  <xsl:otherwise>
									&#160;&#160;&#160;&#160;					   
								  </xsl:otherwise>
								</xsl:choose>					
								&#160;&#160;&#160;&#160;
								<xsl:choose>
								  <xsl:when test="Detail">
									<wbr/><A class="sys-link-normal" style="padding: 0 0 0 0" href="{$DetailURL}">Result details</A>    
								  </xsl:when>
								</xsl:choose>
 								<xsl:if test="$score=1">
 									&#160;&#160;&#160;&#160;					   
 									<A class="sys-link-normal" style="padding: 0 0 0 0" target="_blank" href="Help/mbsahelp.html#howtocorrect">How to correct this</A>					   
 								</xsl:if>																					
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
								  <xsl:when test="@URL1 and @URL1 != '' and @URL1 != ' '">
									<A class="sys-link-normal" style="padding: 0 0 0 0" target="_blank" href="{@URL1}">What was scanned</A>					   
								  </xsl:when>
								  <xsl:otherwise>
									&#160;&#160;&#160;&#160;					   
								  </xsl:otherwise>
								</xsl:choose>					
								&#160;&#160;&#160;&#160;
								<xsl:choose>
								  <xsl:when test="Detail">
									<wbr/><A class="sys-link-normal" style="padding: 0 0 0 0" href="{$DetailURL}">Result details</A>    
								  </xsl:when>
								  <xsl:otherwise>
									&#160;&#160;&#160;&#160;					   
								  </xsl:otherwise>
								</xsl:choose>			
								&#160;&#160;&#160;&#160;
								<xsl:choose>
								  <xsl:when test="@URL2 and @URL2 != '' and @URL2 != ' '">
									<wbr/><A class="sys-link-normal" style="padding: 0 0 0 0" target="_blank" href="{@URL2}">How to correct this</A>					   
								  </xsl:when>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					  </nobr>
					  </TD>
					  </TR>
					</TABLE>
				</td>
			</tr>
	</xsl:template>

</xsl:stylesheet>
