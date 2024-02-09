<?xml version="1.0" encoding="UTF-8"?>
<!-- Converts a schema to a NIEM Light schema that will not require namespace prefixes. Used for transition to NIEM-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:pescfn="urn:org:pesc:functions" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:import href="pesc functions.xslt"/>
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="term-definition">coremain definition.xml</xsl:param>
	<xsl:param name="enum-definition">coremain enum definition.xml</xsl:param>
	<xsl:variable name="prefix" select="pescfn:get-schema-prefix(in-scope-prefixes(/xs:schema),/xs:schema)"/>
<!-- capture all the qualified names of the imported simpleTypes -->	

	
	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>

	
	<!-- Do not copy annotations -->
	<xsl:template match="//xs:annotation|//xs:documentation|//xs:documentation/text()">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="/xs:schema/xs:complexType|/xs:schema/xs:simpleType|/xs:schema/xs:group|//xs:element">
		<xsl:copy copy-namespaces="no">
			<xsl:for-each select="./@*">
				<xsl:copy/>
			</xsl:for-each>
			<xsl:element name="xs:annotation">
				<xsl:element name="xs:documentation">
					<xsl:value-of select="pescfn:get-term-definition(document($term-definition),./@name)"/>
				</xsl:element>
			</xsl:element>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
	<!--comment enumerations-->
	<xsl:template match="xs:enumeration">
		<xsl:copy copy-namespaces="no">
			<xsl:for-each select="./@*">
				<xsl:copy copy-namespaces="no"/>
			</xsl:for-each>
			<xsl:if test="exists(ancestor::xs:simpleType/@name)">
			<xsl:element name="xs:annotation">
				<xsl:element name="xs:documentation">
					<xsl:variable name="simple" select="ancestor::xs:simpleType"/>
					<xsl:value-of select="pescfn:get-enumeration-definition(document($enum-definition),$simple/@name,./@value)"/>
				</xsl:element>
			</xsl:element>
			</xsl:if>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	<!-- template for miscellaneous elements that need to be nested within other elements -->
	<xsl:template match="element()">
		<xsl:copy copy-namespaces="no">
			<xsl:for-each select="./@*">
				<xsl:copy copy-namespaces="no"/>
			</xsl:for-each>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	<!--all other nodes -->
	<xsl:template match="comment()|processing-instruction|text()">
		<xsl:copy/>
	</xsl:template>
</xsl:stylesheet>
