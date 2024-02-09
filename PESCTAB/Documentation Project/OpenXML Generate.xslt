<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--ouputs the header of each element description table-->
	<xsl:template name="output-header">
		<xsl:param name="header"/>
		<xsl:element name="w:p">
			<xsl:element name="w:pPr">
				<xsl:element name="w:pStyle">
					<xsl:attribute name="w:val">Heading1</xsl:attribute>
				</xsl:element>
			</xsl:element>
			<xsl:element name="w:r">
				<xsl:element name="w:t">
					<xsl:value-of select="concat('Element ',$header)"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<!--outputs the diagram associated with the parameters -->
	<xsl:template name="output-diagram">
		<xsl:param name="diagram-number"/>
		<xsl:param name="diagram-name"/>
		<xsl:param name="relationship-id"/>
		<xsl:element name="w:p">
			<xsl:element name="w:r">
				<xsl:element name="w:rPr">
					<xsl:element name="w:noProof"/>
					<xsl:element name="w:drawing">
						<xsl:element name="wp:inline" namespace="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing">
							<xsl:attribute name="distT">0</xsl:attribute>
							<xsl:attribute name="distB">0</xsl:attribute>
							<xsl:attribute name="distL">0</xsl:attribute>
							<xsl:attribute name="distR">0</xsl:attribute>
							<xsl:element name="wp:extent">
								<xsl:attribute name="cx">3981450</xsl:attribute>
								<xsl:attribute name="cy">7534275</xsl:attribute>
							</xsl:element>
							<xsl:element name="wp:docPr" namespace="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing">
								<xsl:attribute name="id" select="$diagram-number"/>
								<xsl:attribute name="name" select="concat('Picture ',$diagram-number)"/>
							</xsl:element>
							<xsl:element name="a:graphic" namespace="http://schemas.openxmlformats.org/drawingml/2006/main">
								<xsl:element name="a:graphicData" namespace="http://schemas.openxmlformats.org/drawingml/2006/main">
									<xsl:attribute name="uri">http://schemas.openxmlformats.org/drawingml/2006/picture</xsl:attribute>
									<xsl:element name="pic:pic" namespace="http://schemas.openxmlformats.org/drawingml/2006/picture">
										<xsl:element name="pic:nvPicPr">
											<xsl:element name="pic:cNvPr">
												<xsl:attribute name="id" select="$diagram-number"/>
												<xsl:attribute name="name" select="$diagram-name"/>
											</xsl:element>
											<xsl:element name="pic:cNvPicPr"/>
										</xsl:element>
										<xsl:element name="pic:blipFill">
											<xsl:element name="a:blip">
												<xsl:attribute name="r:embed" namespace="http://schemas.openxmlformats.org/officeDocument/2006/relationships" select="$relationship-id"/>
											</xsl:element>
											<xsl:element name="a:stretch">
												<xsl:element name="a:fillRect"/>
											</xsl:element>
										</xsl:element>
										<xsl:element name="pic:spPr">
											<xsl:element name="a:xfrm">
												<xsl:element name="a:off">
													<xsl:attribute name="x">0</xsl:attribute>
													<xsl:attribute name="y">0</xsl:attribute>
												</xsl:element>
												<xsl:element name="a:ext">
													<xsl:attribute name="cx">3981450</xsl:attribute>
													<xsl:attribute name="cy">7534275</xsl:attribute>
												</xsl:element>
											</xsl:element>
											<xsl:element name="a:prstGeom">
												<xsl:attribute name="prst">rect</xsl:attribute>
												<xsl:element name="a:avLst"/>
											</xsl:element>
										</xsl:element>
									</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<!--outputs an embedded row-->
	<xsl:template name="output-subtable-row">
		<xsl:param name="property"/>
		<xsl:param name="value"/>
		<xsl:element name="w:tr">
			<xsl:element name="w:tc">
				<xsl:element name="w:p">
					<xsl:element name="w:r">
						<xsl:element name="w:t">
							<xsl:value-of select="$property"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="w:tc">
				<xsl:element name="w:p">
					<xsl:element name="w:r">
						<xsl:element name="w:t">
							<xsl:value-of select="$value"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<!-- creates border around current cell-->
	<xsl:template name="create-borders">
		<xsl:param name="size">12</xsl:param>
		<xsl:param name="color">5b9bd5</xsl:param>
		<xsl:element name="w:tcPr">
			<xsl:element name="w:tcBorders">
				<xsl:for-each select="('w:top','w:left','w:right','w:bottom')">
					<xsl:element name="{data(.)}">
						<xsl:attribute name="w:val">single</xsl:attribute>
						<xsl:attribute name="w:sz" select="$size"/>
						<xsl:attribute name="w:color" select="$color"/>
					</xsl:element>
				</xsl:for-each>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<!--ouputs a row in the element description table-->
	<xsl:template name="output-row">
		<xsl:param name="property"/>
		<xsl:param name="value"/>
		<xsl:param name="definition"/>
		<xsl:element name="w:tr">
			<xsl:element name="w:tc">
				<xsl:call-template name="create-borders"/>
				<xsl:element name="w:p">
					<xsl:element name="w:r">
						<xsl:element name="w:t">
							<xsl:value-of select="$property"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="w:tc">
				<xsl:call-template name="create-borders"/>
				<xsl:choose>
					<xsl:when test="data($property)='Code List'">
						<xsl:element name="w:tbl">
							<xsl:for-each select="$value">
								<xsl:variable name="index" as="xs:integer" select="position()"/>
								<xsl:call-template name="output-subtable-row">
									<xsl:with-param name="property" select="."/>
									<xsl:with-param name="value" select="$definition[$index]"/>
								</xsl:call-template>
							</xsl:for-each>
						</xsl:element>
						<xsl:element name="w:p"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="w:p">
							<xsl:element name="w:r">
								<xsl:element name="w:t">
									<xsl:value-of select="$value"/>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<!-- template outputs a element-->
	<xsl:template name="output-element">
		<xsl:call-template name="output-header">
			<xsl:with-param name="header">AcademicEPortfolio</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="output-diagram">
			<xsl:with-param name="diagram-name">AcademicEPortfolio_v1.0.0_p1.png</xsl:with-param>
			<xsl:with-param name="diagram-number">1</xsl:with-param>
			<xsl:with-param name="relationship-id">rIdx1</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="output-diagram">
			<xsl:with-param name="diagram-name">AcademicEPortfolio_v1.0.0_p3.png</xsl:with-param>
			<xsl:with-param name="diagram-number">1</xsl:with-param>
			<xsl:with-param name="relationship-id">rIdx2</xsl:with-param>
		</xsl:call-template>
		<!--set table width-->
		<xsl:element name="w:tbl">
			<xsl:element name="w:tblPr">
				<xsl:element name="w:tblW">
					<xsl:attribute name="w:w">9615</xsl:attribute>
					<xsl:attribute name="w:type">dxa</xsl:attribute>
				</xsl:element>
			</xsl:element>
			<xsl:call-template name="output-row">
				<xsl:with-param name="property">Description</xsl:with-param>
				<xsl:with-param name="value">This is an element that has a very long sentence so we will see if it wraps. This is an element that has a very long sentence so we will see if it wraps. This is an element that has a very long sentence so we will see if it wraps.</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="output-row">
					<xsl:with-param name="property">Type</xsl:with-param>
					<xsl:with-param name="value">Object</xsl:with-param>
				</xsl:call-template>
			<xsl:call-template name="output-row">
				<xsl:with-param name="property">Code List</xsl:with-param>
				<xsl:with-param name="value" select="('A','MyCode','LongCodeforSizing')"/>
				<xsl:with-param name="definition" select="('Test 1','Test 2','This is a long definition')"/>
			</xsl:call-template>
			</xsl:element>
	</xsl:template>
	<xsl:template match="/">
		<xsl:call-template name="output-element"/>
		<xsl:element name="w:p">
			<xsl:element name="w:r">
				<xsl:element name="w:br">
					<xsl:attribute name="w:type">page</xsl:attribute>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
