<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"	
	xmlns:camed="http://jcam.org.uk/editor"	
	xmlns:as="http://www.oasis-open.org/committees/cam"
	xmlns:look="http://jcam.org.uk/LookupLists"
	xmlns:dblook="http://jcam.org.uk/DbLookupLists"
	exclude-result-prefixes="as camed">
	<xsl:param name="file">File name</xsl:param>
	<xsl:param name="stylesheet">file://styles.css</xsl:param>
	<xsl:output indent="no" media-type="text/html" method="html" encoding="UTF-8"/>
	<xsl:variable name="version">1.07</xsl:variable>
	<xsl:variable name="nbsp" ><xsl:text disable-output-escaping="yes">&#160;&#160;</xsl:text></xsl:variable>
	<xsl:variable name="structureID" select="//as:AssemblyStructure/as:Structure/@ID"/>
	<xsl:variable name="linefeed">
<xsl:text>
</xsl:text>
	</xsl:variable>
	<xsl:template match="/">
		<html>
			<head>
				<style type="text/css">
                	<xsl:variable name="input-text" select="unparsed-text($stylesheet, 'UTF-8')"/>                
                	<xsl:value-of select="$input-text"/>
                </style>				
			</head>
			<body>
				<xsl:apply-templates select="//as:Header"/>
				<xsl:apply-templates select="//as:AssemblyStructure"/>
				<xsl:apply-templates select="//as:Extension"/>
				<!--				<xsl:apply-templates select="//as:BusinessUseContext"/>
				<xsl:apply-templates select="/as:CAM/as:include" mode="extension"/>-->
				<!-- add a blank line at bottom of report -->
				<br/>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="as:Header">
		<h1>
Documentation for: <xsl:value-of select="$structureID[position()]"/>
		</h1>
		<p class="footerNotice">
			<xsl:value-of select="$file"/> (output generator <xsl:value-of select="$version"/>)
		</p>
		<table class="CAM-InfoTable" width="100%">
			<tr>
				<td width="20%">Owner</td>
				<th width="80%">
					<xsl:value-of select="as:Owner"/>
				</th>
			</tr>
			<tr>
				<td>Version</td>
				<th>
					<xsl:value-of select="as:Version"/>
				</th>
			</tr>
			<tr>
				<td>Description</td>
				<td class="CAM-NewsCell">
					<xsl:value-of select="as:Description"/>
				</td>
			</tr>
			<tr>
				<td>Date</td>
				<td>
					<xsl:value-of select="as:DateTime"/>
				</td>
			</tr>
		</table>
		<xsl:apply-templates select="as:Parameters"/>
		<xsl:apply-templates select="as:Imports"/>
		<xsl:apply-templates select="as:Properties"/>
	</xsl:template>
	<xsl:template match="as:Parameters">
		<h2>Parameters</h2>
		<table border="1">
			<tr>
				<th>Name</th>
				<th>Usage</th>
				<th>Values</th>
				<th>Default Value</th>
				<th>xpath</th>
			</tr>
			<xsl:apply-templates select="as:Parameter"/>
		</table>
	</xsl:template>
	<xsl:template match="as:Parameter">
		<tr>
			<td>
				<xsl:value-of select="@name"/>
			</td>
			<td>
				<xsl:value-of select="@use"/>
			</td>
			<td>
				<xsl:value-of select="@values"/>
				<xsl:value-of select="$nbsp"/>
			</td>
			<td>
				<xsl:value-of select="@default"/>
				<xsl:value-of select="$nbsp"/>
			</td>
			<td>
				<xsl:value-of select="@xpath"/>
				<xsl:value-of select="$nbsp"/>
			</td>
		</tr>
	</xsl:template>
	<xsl:template match="as:AssemblyStructure">
		<h1>Assembly Structures</h1>
		<xsl:apply-templates select="as:Structure"/>
	</xsl:template>
	<xsl:template match="as:Element">
	   <xsl:param name="indent"/>
	   <xsl:param name="included"/>
	   <xsl:param name="depth" select="1" />
		<tr>	  
		    <xsl:choose>
			<xsl:when test="$included='true' or @included='true'">
				<td class="topicCell" >
					<div class="topicTextLeftIncluded">
						<xsl:value-of select="$indent"/><span class="depth"><xsl:value-of select="$depth"/></span><xsl:value-of select="$nbsp"/><span class="element"><xsl:value-of select="@name"/></span>			
					</div>
				</td>
			</xsl:when>
			<xsl:otherwise>
				<td class="topicCell">
					<div class="topicTextLeft">
						<xsl:value-of select="$indent"/><span class="depth"><xsl:value-of select="$depth"/></span><xsl:value-of select="$nbsp"/><span class="element"><xsl:value-of select="@name"/></span>					
					</div>
				</td>
			</xsl:otherwise>
			</xsl:choose>
			<td  class="topicCell">
				<div class="topicTextLeft">
					<xsl:apply-templates select="as:Rule"/>
					<xsl:value-of select="$nbsp"/>
				</div>
			</td>
			<td class="topicCell">
				<div class="topicTextLeft">
					<xsl:apply-templates select="camed:annotation"/>
					<xsl:value-of select="$nbsp"/>
				</div>
			</td>
		</tr>
		<xsl:variable name="makeIncluded">
		<xsl:choose>
		<xsl:when test="@included='true'">true</xsl:when>
		<xsl:when test="$included='true'">true</xsl:when>
		<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
		</xsl:variable>
<!--		<xsl:message>makeIncluded = <xsl:value-of select="$makeIncluded"/></xsl:message>
-->		<xsl:apply-templates select="as:Attribute">
			<xsl:with-param name="indent"><xsl:value-of select="$indent"/><xsl:value-of select="$nbsp"/></xsl:with-param>
			<xsl:with-param name="included"><xsl:value-of select="$makeIncluded"/></xsl:with-param>
		</xsl:apply-templates>
		<xsl:apply-templates select="as:Element">
			<xsl:with-param name="indent"><xsl:value-of select="$indent"/><xsl:value-of select="$nbsp"/></xsl:with-param>
			<xsl:with-param name="included"><xsl:value-of select="$makeIncluded"/></xsl:with-param>
			<xsl:with-param name="depth"><xsl:value-of select="$depth + 1"/></xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="as:Attribute">
	  <xsl:param name="indent"/>
	  <xsl:param name="included"/>
		<tr>
		    <xsl:choose>
			<xsl:when test="$included='true' or @included='true'">
				<td class="topicCell">
					<div class="topicTextLeftIncluded">
						<xsl:value-of select="$indent"/>@<xsl:value-of select="@name"/>
					</div>
				</td>

			</xsl:when>
			<xsl:when test="@included='true'">
				<td class="topicCell">
					<div class="topicTextLeftIncluded">
						<xsl:value-of select="$indent"/>@<xsl:value-of select="@name"/>
					</div>
				</td>

			</xsl:when>
			<xsl:otherwise>
				<td class="topicCell">
					<div class="topicTextLeft">
						<xsl:value-of select="$indent"/>@<xsl:value-of select="@name"/>
					</div>
				</td>
			</xsl:otherwise>
			</xsl:choose>
			<td class="topicCell">
				<div class="topicTextLeft">
					<xsl:apply-templates select="as:Rule"/>
					<xsl:value-of select="$nbsp"/>
				</div>
			</td>
			<td class="topicCell">
				<div class="topicTextLeft">
					<xsl:apply-templates select="camed:annotation"/>
					<xsl:value-of select="$nbsp"/>
				</div>
			</td>
		</tr>
	</xsl:template>
	<xsl:template match="camed:annotation">
		<table  width="100%">
			<xsl:apply-templates select="camed:documentation"/>
		</table>
	</xsl:template>
	<xsl:template match="camed:documentation">
		<tr>
			<th class="annotationHeader">
				<xsl:value-of select="@type"/>
			</th>
		</tr>
		<tr>
			<td class="annotationBody">
				<xsl:value-of select="if(contains(substring(.,2),$linefeed)) then concat(substring(.,1,1),replace(substring(.,2),$linefeed,'&lt;br/>&lt;br/>')) else ." disable-output-escaping="yes"/>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="as:annotation">

		<table width="100%">
			<xsl:apply-templates select="as:documentation"/>
		</table>
	</xsl:template>
	<xsl:template match="as:documentation">
<!--		<tr>
			<th class="ruleAnnotationHeader">
				<xsl:value-of select="@type"/>
			</th>
		</tr>-->
		<tr>
			<td >
			 <p class="ruleAnnotationBody">
				<xsl:value-of select="." disable-output-escaping="yes"/>
			 </p>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="as:Rule">
		<table width="100%">
			<xsl:apply-templates select="as:constraint"/>
		</table>
	</xsl:template>
	<xsl:template match="as:constraint">
		<tr>
			<td> 
			   <xsl:choose>
			   <xsl:when test="as:annotation">
			    <table width="100%" >
				 <tr>
				  <td >
				<div class="topicTextLeftSquashed">
					<xsl:choose>
						<xsl:when test="@condition">
<div class="keyword">if <font color="black"><xsl:value-of select="@condition"/></font><br/>then</div> 
							<xsl:choose>
							<xsl:when test="not(contains(@action,'lookup('))">     			
								<div class="indentedTopicTextLeft"><xsl:value-of select="@action"/></div>
							</xsl:when>
							<xsl:otherwise>
								lookup(<xsl:element name="a">
								<xsl:attribute name="href">#<xsl:value-of select="substring-before(substring-after(@action,'lookup('),')')"/></xsl:attribute>
								<xsl:value-of select="substring-after(@action,'lookup(')"/></xsl:element>)
							</xsl:otherwise>
							</xsl:choose>
<div class="keyword">end if;</div>      							
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="outputRule"></xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
					
				</div>
				</td>
				<td width="200" >
				<xsl:apply-templates select="as:annotation"/>
				</td>
				</tr>
				</table>
				</xsl:when>
				<xsl:otherwise>
				<div class="topicTextLeftSquashed">
					<xsl:choose>
						<xsl:when test="@condition">
<div class="keyword">if <font color="black"><xsl:value-of select="@condition"/></font><br/>then</div> 
							<xsl:choose>
							<xsl:when test="not(contains(@action,'lookup('))">     			
								<div class="indentedTopicTextLeft"><xsl:value-of select="@action"/></div>
							</xsl:when>
							<xsl:otherwise>
								lookup(<xsl:element name="a">
								<xsl:attribute name="href">#<xsl:value-of select="substring-before(substring-after(@action,'lookup('),')')"/></xsl:attribute>
								<xsl:value-of select="substring-after(@action,'lookup(')"/></xsl:element>)
							</xsl:otherwise>
							</xsl:choose>
<div class="keyword">end if;</div>      							
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="outputRule"></xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
					
				</div>
				</xsl:otherwise>
				</xsl:choose>					
			</td>
		</tr>
	</xsl:template>
	<xsl:template match="as:Structure">
		<h2>Structure</h2>
		<xsl:if test="string-length(@ID) > 0">
			<h2>
ID:   				<xsl:value-of select="@ID"/>
			</h2>
		</xsl:if>
		<xsl:if test="string-length(@reference) > 0">
			<h2>
Reference:   				<xsl:value-of select="@reference"/>
			</h2>
		</xsl:if>
		<h3>
Taxonomy:  			<xsl:value-of select="@taxonomy"/>
		</h3>
		<table border="1" class="topicTable">
			<tr>
				<td class="path">
					<div class="topicGroupHeaderCell">XPath locator (and depth)</div>
				</td>
				<td class="rule">
					<div class="topicGroupHeaderCell">Rule(s)</div>
				</td>
				<td class="annotation">
					<div class="topicGroupHeaderCell">Annotation</div>
				</td>
			</tr>
			<xsl:apply-templates select="as:Element">
				<xsl:with-param name="indent"></xsl:with-param>
				<xsl:with-param name="included"><xsl:value-of select="false()"/></xsl:with-param>
			</xsl:apply-templates>
		</table>
	</xsl:template>

<xsl:template match="as:Extension">
	<xsl:apply-templates select="look:LookupList"/>
	<xsl:apply-templates select="dblook:DbLookupList"/>
</xsl:template>

<xsl:template match="look:LookupList">
	<table border="0">
		<td>
			<h3>LookupList: <a name="#{@name}"><xsl:value-of select="@name"/></a></h3>
			<table border="1">
			<tr>
				<td class="annotation">
					<div class="topicGroupHeaderCell">Name</div>
				</td>
				<td class="annotation">
					<div class="topicGroupHeaderCell">Type</div>
				</td>
				<td class="annotation">
					<div class="topicGroupHeaderCell">Value</div>
				</td>
				<td class="annotation">
					<div class="topicGroupHeaderCell">Alternative</div>
				</td>
			</tr>
			<xsl:apply-templates select="look:item"/>
			</table>
		</td>
	</table>
</xsl:template>
	
<xsl:template match="dblook:DbLookupList">
	<table border="0">
		<td>
			<h3>SQL DB Lookup: <a name="#{@name}"><xsl:value-of select="@name"/></a></h3>
			<table border="1">
				<tr>
					<td class="annotation">
						<div class="topicGroupHeaderCell">SQL</div>
					</td>
				</tr>
				<tr>
					<td class="annotation">
						<div class="topicTextLeft"><xsl:value-of select="."/></div>
					</td>
				</tr>
			</table>
		</td>
	</table>
</xsl:template>

<xsl:template match="look:item">
		<tr>
			<td>
				<div class="topicTextLeft">
					<xsl:value-of select="@name"/>
				</div>
			</td>
			<td>
				<div class="topicTextLeft">
					<xsl:if test="string-length(@type) > 0">
						<xsl:value-of select="@type"/>
					</xsl:if>
					<xsl:if test="string-length(@type) = 0">
						<font size="0.01em">.</font>
					</xsl:if>
				</div>
			</td>
			<td>
				<div class="topicTextLeft">
					<xsl:value-of select="."/>
				</div>
			</td>
			<td>
				<div class="topicTextLeft">
					<xsl:if test="string-length(@alt) > 0">
						<xsl:value-of select="@alt"/>
					</xsl:if>
					<xsl:if test="string-length(@alt) = 0">
						<font size="0.01em">.</font>
					</xsl:if>
				</div>
			</td>
		</tr>
</xsl:template>
	
<xsl:template name="outputRule">
	<xsl:choose>
		<xsl:when test="@action='makeMandatory()'">     			
			<div class="TopicTextLeft">required item</div>
		</xsl:when>
		<xsl:when test="@action='makeRepeatable()'">     			
			<div class="TopicTextLeft">repeatable item</div>
		</xsl:when>
		<xsl:when test="@action='makeOptional()'">     			
			<div class="TopicTextLeft">optional</div>
		</xsl:when>
		<xsl:when test="contains(@action,'datatype(')">     
			<xsl:choose>
				<xsl:when test="contains(@action,'(any')">
					<div class="TopicTextLeft">with content type of "<xsl:value-of select="substring-before(substring-after(@action,'('),')')"/>"</div>
				</xsl:when>
				<xsl:otherwise>
					<div class="TopicTextLeft">with data type of "<xsl:value-of select="substring-before(substring-after(@action,'('),')')"/>"</div>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="contains(@action,'setNumberMask(')">     
			<xsl:choose>
				<xsl:when test="contains(@action,'.')">
					<div class="TopicTextLeft">decimal number with format "<xsl:value-of select="substring-before(substring-after(@action,'('),')')"/>"</div>
				</xsl:when>
				<xsl:otherwise>
					<div class="TopicTextLeft">numeric with format "<xsl:value-of select="substring-before(substring-after(@action,'('),')')"/>"</div>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="contains(substring-before(@action,'('),'exclude')">     			
			<div class="TopicTextLeft"><b>* E X C L U D E D *</b></div>
		</xsl:when>
		<xsl:when test="contains(@action,'setLimit(')">     			
			<div class="TopicTextLeft"><b>repeat limited to only <xsl:value-of select="substring-before(substring-after(@action,'('),')')"/>  times</b></div>
		</xsl:when>
		<!-- Need to add whitespace to minimize table column width when lots of enumerated values. -->
		<xsl:when test="contains(@action,'restrictValues')">     			
			<div class="TopicTextLeft">Only allowed values are: 
				<xsl:variable name="vals" select="substring-before(substring-after(@action,'('),')')"/> 
				<!-- DEBUG xsl:value-of select="$vals"/ -->
				<xsl:value-of select="replace($vals, '[|]', ' | ')" />
			</div>
		</xsl:when>
		<xsl:when test="contains(@action,'setChoice(')">    
			<xsl:variable name="choices" select="tokenize(substring-after(@action,'['),'''\)')"/>
			<div class="TopicTextLeft"><b>choice item within <xsl:value-of select="substring-before(substring-after(@action,'//'),'/*')"/></b> 				
				<p>(one of <xsl:for-each select="$choices">
					<xsl:choose>
						<xsl:when test="contains(.,'),')">- <xsl:value-of select="substring-after(.,'),''')"/></xsl:when>
						<xsl:otherwise>- <xsl:value-of select="substring-after(.,'=''')"/></xsl:otherwise>
					</xsl:choose> 
				</xsl:for-each> )</p></div>
		</xsl:when>
		<xsl:when test="not(contains(@action,'lookup('))">     			
			<div class="TopicTextLeft"><xsl:value-of select="@action"/></div>
		</xsl:when>
		<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="contains(@action,',')"><div class="TopicTextLeft"><xsl:value-of select="substring-before(@action,',')"/>,<xsl:element name="a"><xsl:attribute name="href">#<xsl:value-of select="substring-before(substring-after(@action,','),')')"/></xsl:attribute><xsl:value-of select="substring-after(@action,',')"/></xsl:element></div></xsl:when>
					<xsl:otherwise><div class="TopicTextLeft"><xsl:value-of select="@action"/></div></xsl:otherwise>
				</xsl:choose>	
		</xsl:otherwise>
	</xsl:choose>
	
</xsl:template>
	
</xsl:stylesheet>
