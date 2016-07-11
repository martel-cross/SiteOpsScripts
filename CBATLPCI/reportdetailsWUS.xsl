<?xml version="1.0"?> 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:variable name="CheckID" select="'CheckIDHere'"></xsl:variable>
	<xsl:variable name="GroupID" select="'GroupIDHere'"></xsl:variable>

	<xsl:variable name="ScoreLookup">
	  <c score="0" url="Graphics/dash.gif" alttext.loc="reportdetail2.text.1" alttext="Check Not Performed"/>
	  <c score="1" url="Graphics/excl_red16.gif" alttext.loc="reportdetail2.text.2" alttext="Unable to scan"/>
	  <c score="2" url="Graphics/mini_x_red.gif" alttext.loc="reportdetail2.missingsecupdate" alttext="Missing security update"/>
	  <c score="3" url="Graphics/mini_x_gold.gif" alttext.loc="reportdetail2.warning" alttext="Warning"/>
	  <c score="4" url="Graphics/info.gif" alttext.loc="reportdetail2.notemessage" alttext="Note message"/>
	  <c score="5" url="Graphics/mini_chek_grn.gif" alttext.loc="reportdetail2.text.6" alttext="Check passed"/>
	  <c score="6" url="Graphics/info.gif" alttext.loc="reportdetail2.text.7" alttext="Additional information"/>
	  <c score="7" url="Graphics/info.gif" alttext.loc="reportdetail2.text.7" alttext="Additional information"/>
	  <c score="8" url="Graphics/mini_star_blu.gif" alttext.loc="reportdetail2.text.8" alttext="Not approved"/>
	</xsl:variable>

	<xsl:variable name="SeverityLookup">
		<c value="4" text.loc="reportdetail2.sev.4" text="Critical"/>
		<c value="3" text.loc="reportdetail2.sev.3" text="Important"/>
		<c value="2" text.loc="reportdetail2.sev.2" text="Moderate"/>
		<c value="1" text.loc="reportdetail2.sev.1" text="Low"/>
		<c value="0" text.loc="reportdetail2.sev.0" text=""/>
	</xsl:variable>

	<xsl:variable name="TooltipText">
		<c value="4" text.loc="TooltipText.4" text="Microsoft Knowledge Base article number"/>
		<c value="3" text.loc="TooltipText.3" text="Microsoft security bulletin number"/>
		<c value="2" text.loc="TooltipText.2" text="Related 3rd party vulnerability numbers"/>
		<c value="1" text.loc="TooltipText.1" text="Security bulletin maximum severity (refer to the bulletin for product-specific severity)."/>
	</xsl:variable>
	
	<xsl:template match="SecScan">
		<xsl:apply-templates select="Check[@ID=$CheckID and @GroupID=$GroupID]"/>
	</xsl:template>	
	
	<xsl:template match="Check">
			<h1><xsl:value-of select="Advice"/></h1>
			<h2>Result Details for <!-- argstart --><xsl:value-of select="@GroupName"/><!-- argend --></h2>
			<table id="TableID" width="100%" border="0" cellpadding="0" cellspacing="0" class="DetailsTable">
	
				<!-- 1st section: Missing critical updates -->
				<xsl:if test="count(Detail/UpdateData[(@IsInstalled='false' or @RestartRequired='true') and @Type=1]) > 0">
					<tr><td colspan="5" class="tdText">
						<h3 style="margin-bottom: 0;">Security Updates</h3>
						
						<p style="margin-top: 4px;">Items marked with <!--argstart--><img alt="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=2]/@alttext}" src="graphics/mini_x_red.gif" width="16" height="16"/><!--argend--> are confirmed missing. 
						Items marked with <!--argstart--><img alt="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=8]/@alttext}" src="graphics/mini_star_blu.gif" width="16" height="16"/><!--argend--> are confirmed missing and are not approved by your system administrator.</p>
					</td></tr>
									
					<tr >
						<td class="DetailHeader" width="32">Score</td>
						<td class="DetailHeader" width="32">ID</td>
						<td class="DetailHeader" width="100%">Description</td>
						<td class="DetailHeader" width="32">Maximum Severity</td>
					</tr>
						
					<xsl:apply-templates select="Detail/UpdateData[(@IsInstalled='false' or @RestartRequired='true') and @Type=1]" mode="missing">
					<xsl:sort select="@Severity" order="descending"/>
					</xsl:apply-templates>

					<tr><td>&#160;</td></tr>
				</xsl:if>
				
				<!-- 2nd section: Missing rollups and service packs -->
				<xsl:if test="count(Detail/UpdateData[(@IsInstalled='false' or @RestartRequired='true') and @Type!=1]) > 0">
					<tr><td colspan="5" class="tdText">
						<h3 style="margin-top: 8px; margin-bottom: 0;">Update Rollups and Service Packs</h3>
										
						<p style="margin-top: 4px;">Items marked with <!--argstart--><img alt="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=3]/@alttext}" src="graphics/mini_x_gold.gif" width="16" height="16"/><!--argend--> are confirmed missing.</p>
					</td></tr>
									
					<tr>
						<td class="DetailHeader" width="32">Score</td>
						<td class="DetailHeader" width="32">ID</td>
						<td class="DetailHeader" width="100%" colspan="2">Description</td>
					</tr>
						
					<xsl:apply-templates select="Detail/UpdateData[(@IsInstalled='false' or @RestartRequired='true') and @Type!=1]" mode="missing">
					<xsl:sort select="@Severity" order="descending"/>
					</xsl:apply-templates>

					<tr><td>&#160;</td></tr>
				</xsl:if>

				<!-- 3rd section: Installed items -->
				<xsl:if test="count(Detail/UpdateData[@IsInstalled='true' and (not(@RestartRequired) or @RestartRequired='false')]) > 0">
					<tr><td colspan="5" class="tdText">
						<h3 style="margin-top: 8px; margin-bottom: 0;">Current Update Compliance</h3>
										
						<p style="margin-top: 4px;">Items marked with <!--argstart--><img alt="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=5]/@alttext}" src="graphics/mini_chek_grn.gif" width="16" height="16"/><!--argend--> represent the most current
						updates protecting your computer. If you have installed a recent update, it may incorporate 
						previous updates that will no longer appear in this list, but are still providing protection.</p>
					</td></tr>
									
					<tr>
						<td class="DetailHeader" width="32">Score</td>
						<td class="DetailHeader" width="32">ID</td>
						<td class="DetailHeader" width="100%">Description</td>
						<td class="DetailHeader" width="32">Maximum Severity</td>
						<td class="DetailHeader">&#160;</td>
					</tr>
						
					<xsl:apply-templates select="Detail/UpdateData[@IsInstalled='true' and (not(@RestartRequired) or @RestartRequired='false')]" mode="installed">
					<xsl:sort select="@Severity" order="descending"/>
					</xsl:apply-templates>

					<tr><td>&#160;</td></tr>
				</xsl:if>
			</table>
			<p>If a service pack is listed, it is recommended that you install it prior to any other items listed.</p>
			<p>Read more about <!--argstart link tag open--><a href="http://www.microsoft.com/technet/security/bulletin/rating.mspx" target="_blank"><!--argend-->bulletin severity<!--argstart link tag open--></a><!--argend--> on Microsoft TechNet.</p>
	</xsl:template>
	
	<xsl:template match="UpdateData" mode="installed">
		<tr>
			<td valign="top" align="center">
				<IMG alt="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=5]/@alttext}" src="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=5]/@url}" />
			</td>
			<td valign="top" nowrap="nowrap">
				<xsl:choose>
					<xsl:when test="not(@ID) or @ID=''">
						&#160;
					</xsl:when>
					<xsl:when test="References/BulletinURL != ''">
						<a target="_blank" href="{References/BulletinURL}">
							<xsl:value-of select="@ID"/>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@ID"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:apply-templates select="References/OtherIDs"/>
			</td>
			<td valign="top">
				<xsl:choose>
					<xsl:when test="References/InformationURL != ''">
						<a target="_blank" href="{References/InformationURL}">
							<xsl:value-of select="Title"/>
						</a>
						<xsl:apply-templates select="@RestartRequired"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="Title"/>
						<xsl:apply-templates select="@RestartRequired"/>
					</xsl:otherwise>
				</xsl:choose>
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
			<td valign="top">&#160;</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="UpdateData" mode="missing">
		<xsl:variable name="grade">
			<xsl:choose>
				<xsl:when test="@WUSApproved and @WUSApproved = 'false'">8</xsl:when>
				<xsl:when test="@Type = 3">3</xsl:when>
				<xsl:when test="@Type = 2 and //SecScan/@IsCSAMode = 'false'">3</xsl:when>
				<xsl:when test="@Type = 2 and //SecScan/@IsCSAMode = 'true'">4</xsl:when>
				<xsl:otherwise>2</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<tr>
			<td valign="top" align="center">
				<IMG alt="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=$grade]/@alttext}" src="{document('')/*/xsl:variable[@name='ScoreLookup']/c[@score=$grade]/@url}" />
			</td>
			<td valign="top" nowrap="nowrap">
				<xsl:choose>
					<xsl:when test="not(@ID) or @ID=''">
						&#160;
					</xsl:when>
					<xsl:when test="References/BulletinURL != ''and (not(@WUSApproved) or @WUSApproved != 'false')">
						<a target="_blank" href="{References/BulletinURL}">
							<xsl:value-of select="@ID"/>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@ID"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:apply-templates select="References/OtherIDs"/>
			</td>
			<xsl:choose>
				<xsl:when test="@Type = 1">
					<td valign="top">
						<xsl:choose>
							<xsl:when test="References/InformationURL != ''and (not(@WUSApproved) or @WUSApproved != 'false')">
								<a target="_blank" href="{References/InformationURL}">
									<xsl:value-of select="Title"/>
								</a>
								<xsl:apply-templates select="@RestartRequired"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="Title"/>
								<xsl:apply-templates select="@RestartRequired"/>
							</xsl:otherwise>
						</xsl:choose>
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
						<xsl:choose>
							<xsl:when test="References/InformationURL != ''and (not(@WUSApproved) or @WUSApproved != 'false')">
								<a target="_blank" href="{References/InformationURL}">
									<xsl:value-of select="Title"/>
								</a>
								<xsl:apply-templates select="@RestartRequired"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="Title"/>
								<xsl:apply-templates select="@RestartRequired"/>
							</xsl:otherwise>
						</xsl:choose>
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
		<table border="0">
			<tr>
				<td style="padding: 0;">
					<img class="nodeclink" src="graphics/exp_expand.gif" border="0" onclick="ToggleOtherIDs(this);"/>
				</td>
				<td style="padding: 0;"><img alt.loc="reportdetailswus.expandcollapse.alt" alt="Expands/Collapses related ID list" src="graphics/pixel.gif" height="1" width="1"/></td>
				<td width="100%" nowrap="nowrap" style="padding: 0;">
					<span class="nodeclink" onclick="ToggleOtherIDs(this);"><i>
						<!--argstart--><xsl:value-of select="count(OtherID)"/><!--argend--> related IDs
					</i></span>
				</td>
			</tr>
			<tr>
				<td style="padding: 0;"/>
				<td style="padding: 0;"/>
				<td style="padding: 0;">
					<div style="display: none;">
						<xsl:apply-templates select="OtherID"/>
					</div>
				</td>
			</tr>
		</table>
	</xsl:template>
	
	<xsl:template match="OtherID">
		<xsl:value-of select="."/><br/>
	</xsl:template>
		
</xsl:stylesheet>
