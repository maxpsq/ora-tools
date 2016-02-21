<?xml version="1.0" encoding="utf-8"?>
<!--
Extensible Stylesheet Language Transformation file to transform
a XML document representing a rowset (table) structure to a
Office Open XML Spreadsheet document (MS-EXcel 2007)

The elements in the XML file must be nested as follows:

<?xml version="1.0" encoding="utf-8" ?>
<Spreadsheet>
 <Row>
  <AUTHOR>Massimo Pasquini</AUTHOR>
  <CREATION>2016-02-20T12:26:04Z</CREATION>
 <Row>
 <Rowset>
  <Row>
    <column_name1>value 1</column_name1>
    <column_name2>value 2</column_name2>
    <column_name3>value 3</column_name3>
  </Row>  
  <Row>
    <column_name1>value 1</column_name1>
    <column_name2>value 2</column_name2>
    <column_name3>value 3</column_name3>
  </Row>  
 </Rowset>
</Spreadsheet>
-->

<xsl:stylesheet version="1.0"
 xmlns="urn:schemas-microsoft-com:office:spreadsheet"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:msxsl="urn:schemas-microsoft-com:xslt"
 xmlns:user="urn:my-scripts"
 xmlns:o="urn:schemas-microsoft-com:office:office"
 xmlns:x="urn:schemas-microsoft-com:office:excel"
 xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" > 
 
<xsl:template match="/">
  <Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
    xmlns:o="urn:schemas-microsoft-com:office:office"
    xmlns:x="urn:schemas-microsoft-com:office:excel"
    xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
    xmlns:html="http://www.w3.org/TR/REC-html40">
    <xsl:apply-templates/>
  </Workbook>
</xsl:template>


<xsl:template match="/*/ROWSET[position()=1]/ROW">
  <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">
    <xsl:for-each select="*">
      <xsl:copy><xsl:apply-templates select="node()"/></xsl:copy>
    </xsl:for-each>
  </DocumentProperties>
</xsl:template>



<xsl:template match="/*/*[position() > 1]">
  <Worksheet>
  <xsl:attribute name="ss:Name">
    <xsl:value-of select="./@worksheet_name"/>
  </xsl:attribute>
    <Table x:FullColumns="1" x:FullRows="1">
      <Row>
        <xsl:for-each select="*[position() = 1]/*">
          <Cell><Data ss:Type="String"><xsl:value-of select="./@column_heading"/></Data></Cell>
        </xsl:for-each>
      </Row>
      <xsl:apply-templates/>
    </Table>
  </Worksheet>
</xsl:template>


<xsl:template match="/*/*[position() > 1]/*">
  <Row>
    <xsl:apply-templates/>
  </Row>
</xsl:template>


<xsl:template match="/*/*[position() > 1]/*/*">
  <Cell>
    <Data><xsl:attribute name="ss:Type"><xsl:value-of select="./@type"/></xsl:attribute>
      <xsl:value-of select="."/>
    </Data>
  </Cell>
</xsl:template>


</xsl:stylesheet>