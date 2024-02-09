<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<!-- Assumptions:-->
	<!-- No groups -->
	<!-- no local element defintions -->
	<!-- No global elements with references to them -->
	<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:template match="/">
		<xsl:result-document href="test.json">
			<xsl:apply-templates/>
		</xsl:result-document>
	</xsl:template>
	<!-- start schema-->
	<xsl:template match="/xs:schema">
		<xsl:text>{</xsl:text>
		<xsl:text>&quot;$schema&quot;:&quot;http://json-schema.org/draft-04/schema#&quot;,</xsl:text>
		<xsl:text>&#10;</xsl:text>
		<xsl:text>&quot;definitions&quot;:{ </xsl:text>
		<xsl:apply-templates/>
		<xsl:text>}}</xsl:text>
	</xsl:template>
	<!-- process top level complex-types-->
	<xsl:template match="/xs:schema/xs:complexType">
		<xsl:if test="not(./@name =/xs:schema/element()[not(name()='xs:import')][1]/@name)">
			<xsl:text>,</xsl:text>
		</xsl:if>
		<xsl:text>&quot;</xsl:text>
		<xsl:value-of select="./@name"/>
		<xsl:text>&quot;</xsl:text>
		<xsl:text>:{</xsl:text>
		<xsl:text>&quot;type&quot;: &quot;object&quot;,</xsl:text>
		<xsl:text>&quot;properties&quot;: {</xsl:text>
		<xsl:call-template name="process-complex-type">
			<xsl:with-param name="complex-type" select="."/>
		</xsl:call-template>
		<xsl:text>}</xsl:text>
	</xsl:template>
	<!--template:-->
	<!--description: takes a simple type and outputs a  xs: type or a xs:restriction base mapping as well as the the facets (e.g., minLength,maxLength,minium, maximum, mininumExclusive, etc), and enumerations-->
	<xsl:template match="/xs:schema/xs:simpleType">
		<xsl:if test="not(./@name =/xs:schema/element()[not(name()='xs:import')][1]/@name)">
			<xsl:text>,</xsl:text>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="exists(./@name)">
				<xsl:text>&quot;</xsl:text>
				<xsl:value-of select="./@name"/>
				<xsl:text>&quot;:{</xsl:text>
				<xsl:call-template name="process-simple-type">
					<xsl:with-param name="simple-type" select="."/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
		<xsl:text>}</xsl:text>
	</xsl:template>
	<xsl:template match="/xs:schema/xs:element">
	<xsl:if test="not(./@name =/xs:schema/element()[not(name()='xs:import')][1]/@name)">
			<xsl:text>,</xsl:text>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="exists(./@name)">
				<xsl:text>&quot;</xsl:text>
				<xsl:value-of select="./@name"/>
				<xsl:text>&quot;:{</xsl:text>
				<xsl:call-template name="process-element">
					<xsl:with-param name="element" select="."/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
		<xsl:text>}</xsl:text>
	</xsl:template>
	<!--processes simple-types to json-->
	<xsl:template name="process-simple-type">
		<xsl:param name="simple-type"/>
		<xsl:choose>
			<xsl:when test="exists($simple-type//xs:restriction/@base)">
				<xsl:variable name="base" select="data($simple-type//xs:restriction/@base)"/>
				<xsl:choose>
					<xsl:when test="substring-before($base,':')='xs'">
						<xsl:text>&quot;type&quot;:</xsl:text>
						<xsl:call-template name="process-w3c-type">
							<xsl:with-param name="attribute-value" select="$simple-type//xs:restriction/@base"/>
						</xsl:call-template>
						<xsl:call-template name="process-facets">
							<xsl:with-param name="simple-type" select="$simple-type"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="restriction-simple-type" select="/xs:schema/xs:simpleType[@name =substring-after($base,':')]"/>
						<xsl:text>&quot;type&quot;:</xsl:text>
						<xsl:call-template name="process-w3c-type">
							<xsl:with-param name="attribute-value" select="$restriction-simple-type//xs:restriction/@base"/>
						</xsl:call-template>
						<xsl:choose>
							<xsl:when test="exists($simple-type//xs:restriction/element())">
								<xsl:call-template name="process-facets">
									<xsl:with-param name="simple-type" select="$simple-type"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="process-facets">
									<xsl:with-param name="simple-type" select="$restriction-simple-type"/>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- process facets outputs facets to JSON for restriction base-->
	<xsl:template name="process-facets">
		<xsl:param name="simple-type"/>
		<xsl:if test="exists($simple-type//xs:enumeration)">
			<xsl:text>,&quot;enum&quot;:[</xsl:text>
			<xsl:for-each select="$simple-type//xs:enumeration">
				<xsl:if test="position()>1">
					<xsl:text>,</xsl:text>
				</xsl:if>
				<xsl:text>&quot;</xsl:text>
				<xsl:value-of select="./@value"/>
				<xsl:text>&quot;</xsl:text>
			</xsl:for-each>
			<xsl:text>]</xsl:text>
		</xsl:if>
		<xsl:if test="exists($simple-type//xs:minLength)">
			<xsl:text>,&quot;minLength&quot;:</xsl:text>
			<xsl:value-of select="format-number($simple-type//xs:minLength/@value,'#')"/>
		</xsl:if>
		<xsl:if test="exists($simple-type//xs:maxLength)">
			<xsl:text>,&quot;maxLength&quot;:</xsl:text>
			<xsl:value-of select="format-number($simple-type//xs:maxLength/@value,'#')"/>
		</xsl:if>
		<xsl:if test="exists($simple-type//xs:minInclusive)">
			<xsl:text>,&quot;minimum&quot;:</xsl:text>
			<xsl:value-of select="format-number($simple-type//xs:minInclusive/@value,'#')"/>
			<xsl:text>,&quot;exclusiveMinimum&quot;:false</xsl:text>
		</xsl:if>
		<xsl:if test="exists($simple-type//xs:maxInclusive)">
			<xsl:text>,&quot;maximum&quot;:</xsl:text>
			<xsl:value-of select="format-number($simple-type//xs:maxInclusive/@value,'#')"/>
			<xsl:text>,&quot;exclusiveMaximum&quot;:false</xsl:text>
		</xsl:if>
		<xsl:if test="exists($simple-type//xs:pattern)">
			<xsl:text>,&quot;pattern&quot;:&quot;</xsl:text>
			<xsl:value-of select="replace($simple-type//xs:pattern/@value,'\\d','[0-9]')"/>
			<xsl:text>&quot;</xsl:text>
		</xsl:if>
		<xsl:if test="exists($simple-type//xs:totalDigits) and not(exists($simple-type//xs:maxInclusive))">
			<xsl:variable name="digits" select="$simple-type//xs:totalDigits/@value" as="xs:integer"/>
			<xsl:variable name="fraction-digits" as="xs:integer">
				<xsl:choose>
					<xsl:when test="exists($simple-type//xs:fractionDigits)">
						<xsl:value-of select="$simple-type//xs:fractionDigits/@value"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="0"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:text>,&quot;maximum&quot;:</xsl:text>
			<xsl:value-of select="string-join((for $i in 1 to ($digits - $fraction-digits) return '9'),'')"/>
			<xsl:text>,&quot;exclusiveMaximum&quot;:false</xsl:text>
		</xsl:if>
	</xsl:template>
	<!-- template: process-complex-types-->
	<xsl:template name="process-complex-type">
		<xsl:param name="complex-type"/>
		<xsl:variable name="element-list">
			<xsl:if test="exists($complex-type/xs:attribute|$complex-type/xs:simpleContent//xs:attribute)">
				<xsl:sequence select="$complex-type/xs:attribute|$complex-type/xs:simpleContent//xs:attribute"/>
			</xsl:if>
			<xsl:if test="exists($complex-type/xs:complexContent/xs:extension/@base)">
				<xsl:call-template name="build-extensions">
					<xsl:with-param name="complex-type" select="$complex-type"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:call-template name="build-element-list">
				<xsl:with-param name="complex-type" select="$complex-type"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:call-template name="process-element-list">
			<xsl:with-param name="element-list" select="$element-list"/>
		</xsl:call-template>
	</xsl:template>
	<!-- template recursively adds extension elements to list of elements-->
	<xsl:template name="build-extensions">
		<xsl:param name="complex-type"/>
		<xsl:variable name="next-type" select="/xs:schema/xs:complexType[@name=substring-after($complex-type/xs:complexContent/xs:extension/@base,':')]"/>
		<xsl:choose>
			<xsl:when test="exists($next-type/xs:extension/@base)">
				<xsl:call-template name="build-extensions">
					<xsl:with-param name="complex-type" select="$next-type"/>
				</xsl:call-template>
				<xsl:call-template name="build-element-list">
					<xsl:with-param name="complex-type" select="$next-type"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="build-element-list">
					<xsl:with-param name="complex-type" select="$next-type"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- inputs a complex type and expands xs:extensions and xs:groups as properties to the current object. It also references the types of elements -->
	<xsl:template name="build-element-list">
		<xsl:param name="complex-type"/>
		<xsl:choose>
			<xsl:when test="exists($complex-type//xs:sequence)">
				<xsl:for-each select="$complex-type//xs:sequence/element()">
					<xsl:choose>
						<xsl:when test="name()='xs:element'">
							<xsl:sequence select="."/>
						</xsl:when>
						<xsl:when test="name()='xs:group'">
							<xsl:variable name="next-group" select="/xs:schema/xs:group[@name=substring-after(./@ref,':')]"/>
							<xsl:call-template name="build-element-list">
								<xsl:with-param name="complex-type" select="$next-group"/>
							</xsl:call-template>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="name() = 'xs:choice'">
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- processes each element in the emplement list for a complex type-->
	<xsl:template name="process-element-list">
		<xsl:param name="element-list"/>
		<xsl:for-each select="$element-list/element()">
			<xsl:if test="position()>1">
				<xsl:text>,</xsl:text>
			</xsl:if>
			<xsl:text>&quot;</xsl:text>
			<xsl:value-of select="./@name"/>
			<xsl:text>&quot;:{</xsl:text>
			<!-- determine if has multiple values -->
			<xsl:choose>
				<xsl:when test="name()='xs:element' and exists(./@maxOccurs) and not(./@maxOccurs = '1')">
					<xsl:text>&quot;type&quot;:&quot;array&quot;,&quot;items&quot;:{</xsl:text>
					<xsl:call-template name="process-element">
						<xsl:with-param name="element" select="."/>
					</xsl:call-template>
					<xsl:text>}</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="process-element">
						<xsl:with-param name="element" select="."/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>}</xsl:text>
		</xsl:for-each>
		<!-- end properties-->
		<xsl:text>}</xsl:text>
		<!-- derermine "required" fields-->
		<xsl:if test="$element-list/element()[not(exists(./@minOccurs)) or ./@minOccurs>0 or ./@use='required']">
			<xsl:text>,&quot;required&quot;:[</xsl:text>
		</xsl:if>
		<xsl:for-each select="$element-list/element()[not(exists(./@minOccurs)) or ./@minOccurs>0 or ./@use='required']">
			<xsl:if test="position()>1">
				<xsl:text>,</xsl:text>
			</xsl:if>
			<xsl:text>&quot;</xsl:text>
			<xsl:value-of select="./@name"/>
			<xsl:text>&quot;</xsl:text>
			<xsl:if test="position()=last()">
				<xsl:text>]</xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<!--TEMPLATE: process-elements-->
	<!--Param: element with type defintion-->
	<!--Description: creates a json elements either for a type that is a w3c-type or a type in this schema-->
	<xsl:template name="process-element">
		<xsl:param name="element"/>
		<!--wc3 type-->
		<xsl:choose>
			<xsl:when test="substring-before($element/@type,':')='xs'">
				<xsl:text>&quot;type&quot;:</xsl:text>
				<xsl:call-template name="process-w3c-type">
					<xsl:with-param name="attribute-value" select="data($element/@type)"/>
				</xsl:call-template>
			</xsl:when>
			<!--local simple-type-->
			<xsl:when test="exists($element/xs:simpleType)">
				<xsl:call-template name="process-simple-type">
					<xsl:with-param name="simple-type" select="$element/xs:simpleType"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="exists($element/xs:complexType) and not(exists($element/xs:complexType/xs:simpleContent))">
				<xsl:text>&quot;type&quot;:&quot;object&quot;,&quot;properties&quot;:{</xsl:text>
				<xsl:call-template name="process-complex-type">
					<xsl:with-param name="complex-type" select="$element/xs:complexType"/>
				</xsl:call-template>
				<xsl:text></xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>&quot;$ref&quot;:&quot;#/definitions/</xsl:text>
				<xsl:value-of>
					<xsl:choose>
						<xsl:when test="contains($element/@type,':')">
							<xsl:value-of select="substring-after($element/@type,':')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$element/@type"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:value-of>
				
				<xsl:text>&quot;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- create json for elements that have xs: types -->
	<xsl:template name="process-w3c-type">
		<xsl:param name="attribute-value"/>
		<xsl:variable name="day" select="string('(0[1-9]|[1-2][0-9]|3[0-1])')" as="xs:string"/>
		<xsl:variable name="month" select="string('(0[1-9]|1[0-2])')" as="xs:string"/>
		<xsl:variable name="year" select="string('[0-9]{4}')"/>
		<xsl:choose>
			<xsl:when test="$attribute-value='xs:string' or $attribute-value = 'xs:token'">
				<xsl:text>&quot;string&quot;</xsl:text>
			</xsl:when>
			<xsl:when test="$attribute-value='xs:date' or $attribute-value='xs:dateTime'">
				<xsl:text>&quot;string&quot;,&quot;format&quot;:&quot;date-time&quot;</xsl:text>
			</xsl:when>
			<xsl:when test="$attribute-value= 'xs:integer'">
				<xsl:text>&quot;integer&quot;</xsl:text>
			</xsl:when>
			<xsl:when test="$attribute-value='xs:positiveInteger'">
				<xsl:text>&quot;integer&quot;</xsl:text>
				<xsl:text>,&quot;minium&quot;:1,&quot;minExclusive&quot;:false</xsl:text>
			</xsl:when>
			<xsl:when test="$attribute-value='xs:decimal'">
				<xsl:text>&quot;number&quot;</xsl:text>
			</xsl:when>
			<xsl:when test="$attribute-value='xs:boolean'">
				<xs:text>&quot;boolean&quot;</xs:text>
			</xsl:when>
			<xsl:when test="$attribute-value='xs:gYear'">
				<xsl:text>&quot;string&quot;,&quot;pattern&quot;:&quot;</xsl:text>
				<xsl:value-of select="$year"/>
				<xsl:text>&quot;</xsl:text>
			</xsl:when>
			<xsl:when test="$attribute-value='xs:gYearMonth'">
				<xsl:text>&quot;string&quot;,&quot;pattern&quot;:&quot;</xsl:text>
				<xsl:value-of select="concat($year,'-',$month)"/>
				<xsl:text>&quot;</xsl:text>
			</xsl:when>
			<xsl:when test="$attribute-value='xs:gMonthDay'">
				<xsl:text>&quot;string&quot;,&quot;pattern&quot;:&quot;</xsl:text>
				<xsl:value-of select="concat('--',$month,'-',$day)"/>
				<xsl:text>&quot;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>&quot;string&quot;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="node()|comment()">
		<xsl:apply-templates/>
	</xsl:template>
</xsl:stylesheet>
