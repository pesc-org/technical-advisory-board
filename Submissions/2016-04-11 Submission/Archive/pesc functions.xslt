<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:pescfn ="urn:org:pesc:functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<!--=================================================================================-->
	<!-- function convert-camel-to-def: Takes a CamelCase phrase and breaks it to make a sentence. For use in creation of NIEM like schema-->
	<!--param camel-string: string in CamelCase that needs to be separate into words -->
	<xsl:function name="pescfn:convert-camel-to-def" as="xs:string">
		<xsl:param name="camel-string" as="xs:string"/>
			<xsl:sequence select="replace(replace($camel-string,'([A-Z]+[a-z0-9]+)','$1 '),'([A-Z])([A-Z][a-z0-9])','$1 $2')"/>
	</xsl:function>
	<!--==================================================================================-->
	<!--function get-schema-prefix: takes a sequence of prefixes and selects the one that is mapped to the targetNamespace -->
	<!--param prefixlist: sequence of prefix strings that have assocated namespaces-->
	<!--param schema: schema element for current document that is associated with namespace-->
	<xsl:function name="pescfn:get-schema-prefix" as="xs:string">
	<xsl:param name="prefixlist"/>
	<xsl:param name="schema"/>
	<xsl:variable name="target" select="$schema/@targetNamespace" />
	<xsl:choose>
		<xsl:when test="fn:exists($schema[$target  = namespace-uri-for-prefix($prefixlist[1],$schema)])">
			<xsl:sequence select="$prefixlist[1]"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="pescfn:get-schema-prefix(fn:remove($prefixlist,1),$schema)"/>
		</xsl:otherwise>
	</xsl:choose>
	</xsl:function>
	<!--=========================================================================-->
	<!-- function that extracts defintion for types -->
	<xsl:function name="pescfn:get-term-definition">
		<xsl:param name="defs" />
		<xsl:param name="term-name" as="xs:string"/>
				<xsl:sequence select="$defs//Definition[../Term = $term-name]"/>
	</xsl:function>
	<!--========================================================================-->
	<xsl:function name="pescfn:get-enumeration-definition">
		<xsl:param name="defs" />
		<xsl:param name="type-name" as="xs:string"/>
		<xsl:param name="enum-name" as="xs:string"/>
		<xsl:variable name="def" select="$defs//Line/Definition[../Term = $type-name and ../Enumeration = $enum-name]"/>
		<xsl:choose>
			<xsl:when test="empty($def)">
				<xsl:sequence select="pescfn:convert-camel-to-def($enum-name)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="$def"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	<!-- Test template for functions -->
	<xsl:template match="/">
		<xsl:element name="test">
			<xsl:value-of select="pescfn:get-term-definition(document('coremain enum definition.xml'),'ReligiousAffiliationCode')"/>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>