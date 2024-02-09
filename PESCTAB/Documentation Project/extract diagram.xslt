<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:variable name="schema-library">
		<xsl:value-of select="/w:document/w:body/w:p[1]/w:r[2]/w:t[1]"/>
	</xsl:variable>
	<xsl:template match="/">
		<xsl:element name="diagrams">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="//w:p[data(./w:r/w:t)='element']">
		<xsl:element name="diagram">
			<xsl:element name="library">
				<xsl:value-of select="$schema-library"/>
			</xsl:element>
			<xsl:element name="element">
				<xsl:value-of select="./w:r[3]/w:t"/>
			</xsl:element>
			<xsl:element name="image">
				<xsl:value-of select="following-sibling::w:tbl[1]//pic:cNvPr/@name"/>
			</xsl:element>
		</xsl:element>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
	<xsl:template match="text()"/>
</xsl:stylesheet>
