<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:act="http://www.act.org">
	<xsl:output method="html" version="4.0" encoding="UTF-8" indent="yes"/>
	
	<!--xsl:variable select="document('AdmissionsRecord_v1.0.0.xsd')"-->
	<xsl:variable name="core-prefix" select="'core'"/>
	<!--aggregate all referenced shemas into a single variable -->
	<xsl:variable name="composed-schema" as="document-node()*">
			<xsl:variable name="doc-list" as="document-node()*">
				<xsl:call-template name="compose-schema">
						<xsl:with-param name="current-document" select="/" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:for-each select="$doc-list/document-node()[not(xs:schema/@targetNamespace = preceding-sibling::xs:schema/@targetNamespace)]">
				<xsl:sequence select = "."/>
			</xsl:for-each>
	</xsl:variable>
	<!-- map the prefix names in the same order as the schemas in composed-schema so 
          that index-of ($prefixes, $prefix) may be used as an index into composed-schema -->
	<xsl:variable name="prefixes" as="item()*">
		<xsl:for-each select = "$composed-schema/xs:schema">
			<xsl:variable name="schema" select="."/>
			<xsl:for-each select="in-scope-prefixes($schema)">
				<xsl:if test="namespace-uri-for-prefix(.,$schema)=$schema/@targetNamespace">
					<xsl:sequence select="."/>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="old-sector" as="item()">
		<xsl:variable name="pi" select="//processing-instruction('xslt')"/>
		<xsl:copy-of select="document(substring-before(substring-after($pi,'old-sector=&quot;'),'&quot;'))"/>
	</xsl:variable>

	<xsl:variable name="top-level-prefix" select="$prefixes[1]"/>
	<!-- Assumes root element is the first element in the schema -->
	<xsl:variable name="top-level-element-name" select="/xs:schema/xs:element[1]/@name"/>
	<!-- tempate to create sequence of documents -->
	<xsl:template name="compose-schema">
		<xsl:param name="current-document"/>
		<xsl:sequence select = "$current-document"/>
		<xsl:for-each select="$current-document/xs:schema/xs:import">
			<xsl:variable name="name-space" select="./@namespace"/>
			<xsl:variable name="file-name" select="./@schemaLocation"/>
			<xsl:variable name="new-document" select="document($file-name)"/>
				<xsl:call-template name="compose-schema">
					<xsl:with-param name="current-document" select="$new-document"/>
				</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="/">
		
		<html>
			<head>
				<title>Schema Elements</title>
			</head>
			<body>
				<table id="Schema Elements" border="1">
					<tbody>
						<tr>
							<th>Sector Library</th>
							<th>Tag Name</th>
							<th>Business Term</th>
							<th>Defintion</th>
							<th>Related Terms</th>
							<th>Data Type</th>
							<th>Cardinality</th>
							<th>Min Length</th>
							<th>Max Length</th>
							<th>Pattern</th>
							<th>Enumeration</th>
							<th>Component Type</th>
							<th>Parents</th>
							<th>Children</th>
							<th>Element in AdmRec</th>
							<th>Type in AdmRec</th>
							<th>Type in Core</th>
						</tr>
						<xsl:for-each select="(/xs:schema/(xs:complexType|xs:group)//xs:element)|/xs:schema/xs:element">
							<xsl:call-template name="output-element">
								<xsl:with-param name="elem" select="."/>
								<xsl:with-param name="parent" select="''"/>
								<xsl:with-param name="elem-namespace" select="$top-level-prefix"/>
								<xsl:with-param name="ref-element" select="."/>
							</xsl:call-template>
							</xsl:for-each>
					</tbody>
				</table>
			</body>
		</html>
	</xsl:template>
	<!--
		template output-element -->
	<xsl:template name="output-element">
		<xsl:param name="elem"/>
		<xsl:param name="parent"/>
		<xsl:param name="elem-namespace"/>
		<xsl:param name="ref-element"/>
		<xsl:variable name="type-name" select="substring-after(data($elem/@type),':')"/>
		<xsl:variable name="restriction-prefix" select="substring-before(data($elem//xs:restriction/@base),':')"/>
		<xsl:variable name="extension-prefix" select="substring-before(data($elem//xs:extension/@base),':')"/>
		<xsl:variable name="prefix" select="substring-before(data($elem/@type),':')"/>
		<xsl:variable name="derived-name" select="concat(data($elem/@name),'Type')"/>
		<xsl:choose>
			<xsl:when test="exists($elem/@ref)">
				<xsl:variable name = "ref-element-name" select="substring-after(data($elem/@ref),':')"/>
				<xsl:variable name="ref-prefix" select="substring-before(data($elem/@ref),':')"/>
				<xsl:variable name="document" select="$composed-schema[index-of($prefixes,$prefix)]"/>
				<xsl:call-template name="output-element">
					<xsl:with-param name="elem" select="$document//xs:element[@name=$ref-element-name]"/>
					<xsl:with-param name="parent" select="$parent"/>
					<xsl:with-param name="elem-namespace" select="$ref-prefix"/>
					<xsl:with-param name="ref-element" select="$elem"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="not(empty(data($elem/@name)))">
				<tr>
					<!-- Sector Library -->
					<td>
						<xsl:value-of select="$elem-namespace"/>
					</td>
					<!-- Tag Name -->
					<td>
							<xsl:value-of select="$elem/@name"/>
					</td>
					<!-- Business Term -->
					<td>NA</td>
					<!-- Definition -->
					<xsl:choose>
						<xsl:when test="exists(data($elem//xs:documentation))">
							<td>
								<xsl:value-of select="data($elem//xs:documentation)"/>
							</td>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="get-documentation">
								<xsl:with-param name="elem" select="$elem"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
					<!-- Related Terms -->
					<td>NA</td>
					<!-- Data Type -->
					<td>
						<xsl:value-of select="($elem/@type|$elem//xs:restriction/@base|$elem//xs:extension/@base)[1]"/>
					</td>
					<!-- Cardinality -->
					<td>
						<xsl:call-template name="cardinality">
							<xsl:with-param name="elem" select="$ref-element"/>
						</xsl:call-template>
					</td>
					<!-- Simple Type Attributes: Min Length, Max Length, Pattern and Enumeration List -->
					<!-- see if element has restriction -->
					<xsl:choose>
						<!--embedded simple type-->
						<xsl:when test="$elem/xs:simpleType">
							<xsl:call-template name="output-simpletype">
								<xsl:with-param name="simpletype" select="$elem/xs:simpleType"/>
							</xsl:call-template>
						</xsl:when>
						<!-- no type specified or complex embedded so no restrictions-->
						<xsl:when test="empty(data($elem/@type))">
							<td>NA</td>
							<td>NA</td>
							<td>NA</td>
							<td>NA</td>
							<td>Simple</td>
						</xsl:when>
						<xsl:when test="exists($elem/xs:complexType)">
							<td>NA</td>
							<td>NA</td>
							<td>NA</td>
							<td>NA</td>
							<td>Complex</td>
						</xsl:when>
						<!-- externally defined type -->
						<xsl:otherwise>
							<xsl:call-template name="output-type-info">
								<xsl:with-param name="elem" select="$elem"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
					<td>
						<xsl:value-of select="$parent"/>
					</td>
					<!-- get list of children nodes -->
					<td>
						<xsl:call-template name="get-children">
							<xsl:with-param name="elem" select="$elem"/>
						</xsl:call-template>
					</td>
					<!-- determine if a new element -->
					<td>
						<xsl:value-of select="empty($old-sector//xs:element[@name = $elem/@name])"/>
					</td>
					<td>
						<xsl:value-of select="empty($old-sector//(xs:complexType | xs:simpleType)[@name = $derived-name])"/>
					</td>
					<td>
						<xsl:variable name="doc" select="$composed-schema[index-of($prefixes,$core-prefix)]"/>
						<xsl:value-of select="empty($doc//(xs:complexType | xs:simpleType)[@name = $derived-name])"/>
					</td>
				</tr>
				<!--check for subelements and output -->
				<!--
				<xsl:choose>
					<xsl:when test="$parent=''">
						<xsl:call-template name="get-children-elements">
							<xsl:with-param name="elem" select="$elem"/>
							<xsl:with-param name="parent" select="data($elem/@name)"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="get-children-elements">
							<xsl:with-param name="elem" select="$elem"/>
							<xsl:with-param name="parent" select="concat($parent,'.',data($elem/@name))"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			-->
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- 
	Template: output-simpletype -->
	<!-- Simple Type Processing -->
	<xsl:template name="output-simpletype">
		<xsl:param name="simpletype"/>
		<xsl:choose>
			<xsl:when test="exists($simpletype)">
				<xsl:choose>
					<xsl:when test="exists($simpletype//xs:length/@value)">
						<td>
							<xsl:value-of select="$simpletype//xs:length/@value"/>
						</td>
						<td>
							<xsl:value-of select="$simpletype//xs:length/@value"/>
						</td>
					</xsl:when>
					<xsl:otherwise>
						<td>
							<xsl:call-template name="output-value">
								<xsl:with-param name="data-value" select="$simpletype//xs:minLength/@value"/>
							</xsl:call-template>
						</td>
						<td>
							<xsl:call-template name="output-value">
								<xsl:with-param name="data-value" select="$simpletype//xs:maxLength/@value"/>
							</xsl:call-template>
						</td>
					</xsl:otherwise>
				</xsl:choose>
				<td>
					<xsl:call-template name="output-value">
						<xsl:with-param name="data-value" select="$simpletype//xs:pattern/@value"/>
					</xsl:call-template>
				</td>
				<td>
					<xsl:for-each select="$simpletype//xs:enumeration">
						<xsl:value-of select="@value"/>
						<xsl:text>|</xsl:text>
					</xsl:for-each>
					<xsl:if test="empty($simpletype//xs:enumeration)">
						<xsl:text>NA</xsl:text>
					</xsl:if>
				</td>
				<td>Simple</td>
			</xsl:when>
			<xsl:otherwise>
				<!--  Complex type -->
				<td>NA</td>
				<td>NA</td>
				<td>NA</td>
				<td>NA</td>
				<td>Complex</td>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- 
		template cardinality -->
	<!-- template to output cardinality of element -->
	<xsl:template name="cardinality">
		<xsl:param name="elem"/>
		<xsl:choose>
			<xsl:when test="$elem[@nillable =true]">
				<xsl:text>0</xsl:text>
			</xsl:when>
			<xsl:when test="empty($elem/@minOccurs)">
				<xsl:text>1</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$elem/@minOccurs"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>..</xsl:text>
		<!-- maxOccurs-->
		<xsl:choose>
			<xsl:when test="empty($elem/@maxOccurs)">
				<xsl:text>1</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$elem/@maxOccurs"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- template that gets children based on an external type -->
	<xsl:template name="get-children">
		<xsl:param name="elem"/>
		<xsl:variable name="prefix" select="substring-before(data($elem/@type),':')"/>
		<xsl:variable name="type-name" select="substring-after(data($elem/@type),':')"/>
		<xsl:choose>
			<xsl:when test="exists($elem//xs:element)">
				<xsl:for-each select="$elem//xs:element">
					<xsl:value-of select="@name"/>
					<xsl:text>|</xsl:text>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="$prefix !=''">
				<xsl:variable name="doc" select="$composed-schema[index-of($prefixes,$prefix)]"/>
				<xsl:for-each select="$doc//xs:complexType[@name=$type-name]//(xs:element|xs:group)">
					<xsl:choose>
						<xsl:when test="name(.) = 'xs:group'">
							<xsl:call-template name="get-group-children">
									<xsl:with-param name="elem" select="."/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@name"/>
							<xsl:text>|</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
					
				</xsl:for-each>
				<xsl:if test="empty($doc//(xs:complexType|xs:group)[@name=$type-name]//(xs:element|xs:group))">
					<xsl:text>NA</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>NA</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--get each of names of element in a group-->
	<xsl:template name="get-group-children">
	<xsl:param name="elem"/>
	<xsl:choose>
			<!-- if a reference resolve to a group -->
			<xsl:when test="exists($elem/@ref)">
				<xsl:variable name = "ref-element-name" select="substring-after(data($elem/@ref),':')"/>
				<xsl:variable name="ref-prefix" select="substring-before(data($elem/@ref),':')"/>
				<xsl:variable name="document" select="$composed-schema[index-of($prefixes,$ref-prefix)]"/>
				<xsl:call-template name="get-group-children">
					<xsl:with-param name="elem" select="$document//xs:group[@name=$ref-element-name]"/>
				</xsl:call-template>
			</xsl:when>
			<!-- if a group output group elements -->
			<xsl:when test="exists($elem/@name)">
				<xsl:for-each select="$elem//xs:element">
					<xsl:value-of select="@name"/>
					<xsl:text>|</xsl:text>
				</xsl:for-each>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!--get each of the elements in a group-->
	<xsl:template name="get-group-elements">
		<xsl:param name="elem"/>
		<xsl:param name="parent"/>
		<xsl:param name="prefix"/>
		<xsl:variable name="group-name" select="data($elem/@name)"/>
		<xsl:choose>
			<!-- if a reference resolve to a group -->
			<xsl:when test="exists($elem/@ref)">
				<xsl:variable name = "ref-element-name" select="substring-after(data($elem/@ref),':')"/>
				<xsl:variable name="ref-prefix" select="substring-before(data($elem/@ref),':')"/>
				<xsl:variable name="document" select="$composed-schema[index-of($prefixes,$ref-prefix)]" />
				<xsl:call-template name="get-group-elements">
					<xsl:with-param name="elem" select="$document//xs:group[@name=$ref-element-name]"/>
					<xsl:with-param name="parent" select="$parent"/>
					<xsl:with-param name="prefix" select="$ref-prefix"/>
				</xsl:call-template>
			</xsl:when>
			<!-- if a group output group elements -->
			<xsl:when test="exists($elem/@name)">
				<xsl:for-each select="$elem//xs:element">
					<xsl:call-template name="output-element">
						<xsl:with-param name="elem" select="."/>
						<xsl:with-param name="parent" select="$parent"/>
						<xsl:with-param name="elem-namespace" select="$prefix"/>
						<xsl:with-param name="ref-element" select="."/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- get each of the elements in a complex type -->
	<xsl:template name="get-children-elements">
		<xsl:param name="elem"/>
		<xsl:param name="parent"/>
		<xsl:variable name="type-name" select="substring-after(data($elem/@type),':')"/>
		<xsl:variable name="prefix" select="substring-before(data($elem/@type),':')"/>
		<xsl:choose>

			<xsl:when test="exists(index-of($prefixes,$prefix))">
				<xsl:variable name="doc" select="$composed-schema[index-of($prefixes,$prefix)]"/>
				<xsl:for-each select="$doc//xs:complexType[@name=$type-name]//(xs:element|xs:group)">
					<xsl:choose>
							<xsl:when test="name(.)='xs:group'">
								<xsl:call-template name="get-group-elements">
								<xsl:with-param name="elem" select="."/>
								<xsl:with-param name="parent" select="$parent"/>
								<xsl:with-param name="prefix" select="$prefix"/>
							</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="output-element">
									<xsl:with-param name="elem" select="."/>
									<xsl:with-param name="parent" select="$parent"/>
									<xsl:with-param name="elem-namespace" select="$prefix"/>
									<xsl:with-param name="ref-element" select="."/>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="exists($elem//xs:element)">
				<xsl:for-each select="$elem//xs:element">
					<xsl:call-template name="output-element">
						<xsl:with-param name="elem" select="."/>
						<xsl:with-param name="parent" select="$parent"/>
						<xsl:with-param name="elem-namespace" select="substring-before(data(./@type),':')"/>
						<xsl:with-param name="ref-element" select="."/>
					</xsl:call-template>	
				</xsl:for-each>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!-- template to fill out attribtures of a simpletype -->
	<xsl:template name="output-type-info">
		<xsl:param name="elem"/>
		<xsl:variable name="type-name" select="substring-after(data($elem/@type),':')"/>
		<xsl:variable name="prefix" select="substring-before(data($elem/@type),':')"/>
		<xsl:choose>
			<xsl:when test=" exists(index-of($prefixes,$prefix))">
				<xsl:variable name="doc" select="$composed-schema[index-of($prefixes, $prefix)]"/>
				<xsl:call-template name="output-simpletype">
					<xsl:with-param name="simpletype" select="$doc//xs:simpleType[@name=$type-name]"/>
				</xsl:call-template>
			</xsl:when>
			<!-- predefined xs type -->
			<xsl:when test="$prefix='xs'">
				<td>NA</td>
				<td>NA</td>
				<td>NA</td>
				<td>NA</td>
				<td>Simple</td>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!--
	template output-value
	 -->
	<!-- Create HTML table cell for value -->
	<xsl:template name="output-value">
		<xsl:param name="data-value"/>
		<xsl:choose>
			<xsl:when test="empty(data($data-value))">
				<xsl:text>NA</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$data-value"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	
	
<!--
Template get-documentation
-->
	<xsl:template name="get-documentation">
		<xsl:param name="elem"/>
		<xsl:variable name="prefix" select="substring-before(data($elem/@type),':')"/>
		<xsl:variable name="type-name" select="substring-after(data($elem/@type),':')"/>
		<xsl:variable name="doc" select="$composed-schema[index-of($prefixes,$prefix)]"/>
		<xsl:choose>
			<xsl:when test="exists($doc//xs:complexType[@name = $type-name]/xs:annotation/xs:documentation)">
				<td>
					<xsl:value-of select="data($doc//xs:complexType[@name = $type-name]/xs:annotation/xs:documentation)"/>
				</td>
			</xsl:when>
			<xsl:when test="exists($doc//xs:simpleType[@name = $type-name]/xs:annotation/xs:documentation)">
				<td>
					<xsl:value-of select="data($doc//xs:simpleType[@name = $type-name]/xs:annotation/xs:documentation)"/>
				</td>
			</xsl:when>
			<xsl:otherwise>
				<td>NA</td>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>
