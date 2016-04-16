<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions"
xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0" xmlns:presentation="urn:oasis:names:tc:opendocument:xmlns:presentation:1.0" xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0" xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0" xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0" xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0" xmlns:ooo="http://openoffice.org/2004/office" xmlns:ooow="http://openoffice.org/2004/writer" xmlns:oooc="http://openoffice.org/2004/calc" xmlns:dom="http://www.w3.org/2001/xml-events" xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:rpt="http://openoffice.org/2005/report" xmlns:of="urn:oasis:names:tc:opendocument:xmlns:of:1.2" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:grddl="http://www.w3.org/2003/g/data-view#" xmlns:tableooo="http://openoffice.org/2009/table" xmlns:field="urn:openoffice:names:experimental:ooo-ms-interop:xmlns:field:1.0" > 

<xsl:template match="/">
<office:document-content>
  <office:scripts />
    <office:font-face-decls>
      <style:font-face style:name="Arial" svg:font-family="Arial" style:font-family-generic="swiss" style:font-pitch="variable" />
      <style:font-face style:name="Arial Unicode MS" svg:font-family="'Arial Unicode MS'" style:font-family-generic="system" style:font-pitch="variable" />
      <style:font-face style:name="Tahoma" svg:font-family="Tahoma" style:font-family-generic="system" style:font-pitch="variable" />
    </office:font-face-decls>
    <office:automatic-styles>
      <style:style style:name="co1" style:family="table-column">
        <style:table-column-properties fo:break-before="auto" style:column-width="2.267cm" />
      </style:style>
      <style:style style:name="ro1" style:family="table-row">
      <style:table-row-properties style:row-height="0.42cm" fo:break-before="auto" style:use-optimal-row-height="true" /></style:style>
      <style:style style:name="ta1" style:family="table" style:master-page-name="Default">
        <style:table-properties table:display="true" style:writing-mode="lr-tb" />
      </style:style>
      <number:date-style style:name="N37" number:automatic-order="true">
      <number:day number:style="long" />
      <number:text>/</number:text>
      <number:month number:style="long" />
      <number:text>/</number:text>
      <number:year />
    </number:date-style>
    <style:style style:name="ce1" style:family="table-cell" style:parent-style-name="Default" style:data-style-name="N37" />
  </office:automatic-styles>
  <office:body>
    <office:spreadsheet>
      <xsl:apply-templates/>
    </office:spreadsheet>
  </office:body>
</office:document-content>
</xsl:template>

<xsl:template match="/*/*[position() = 1]">
</xsl:template>

<xsl:template match="/*/*[position() > 1]">
  <table:table table:style-name="ta1" table:print="false">
    <xsl:attribute name="table:name"><xsl:value-of select="./@worksheet_name"/></xsl:attribute>
    <table:table-column table:style-name="co1" table:default-cell-style-name="Default" />
    <table:table-row table:style-name="ro1">
    <xsl:for-each select="*[position() = 1]/*">
       <table:table-cell office:value-type="string">
         <text:p><xsl:value-of select="./@column_heading"/></text:p>
       </table:table-cell>
    </xsl:for-each>
    </table:table-row>
    <xsl:apply-templates/>
  </table:table>
</xsl:template>

<xsl:template match="/*/*/*">
  <table:table-row table:style-name="ro1">
    <xsl:apply-templates/>
  </table:table-row>
</xsl:template>


<xsl:template match="/*/*[position() > 1]/*/*[@oratype='DATE']">
  <table:table-cell table:style-name="ce1" office:value-type="date">
    <xsl:attribute name="office:date-value"><xsl:value-of select="substring-before(substring-before(.,'.000'),'T00:00:00')"/></xsl:attribute>
    <text:p><xsl:value-of select="substring-before(.,'T')"/></text:p>
  </table:table-cell>
</xsl:template>

<xsl:template match="/*/*[position() > 1]/*/*[@oratype='TIMESTAMP' or @oratype='TIMESTAMP WITH TIME ZONE' or @oratype='TIMESTAMP WITH LOCAL TIMEZONE']">
  <table:table-cell table:style-name="ce1" office:value-type="date">
    <xsl:attribute name="office:date-value"><xsl:value-of select="substring-before(.,'.000')"/></xsl:attribute>  
    <text:p><xsl:value-of select="translate(substring-before(.,'.000'), 'T', ' ')"/></text:p>
  </table:table-cell>
</xsl:template>

<xsl:template match="/*/*[position() > 1]/*/*[@oratype='NUMBER']">
  <table:table-cell table:style-name="ce1" office:value-type="float">
    <xsl:attribute name="office:value"><xsl:value-of select="."/></xsl:attribute>
    <text:p><xsl:value-of select="."/></text:p>
  </table:table-cell>
</xsl:template>

<xsl:template match="/*/*[position() > 1]/*/*[@oratype='VARCHAR2' or @oratype='CHAR']">
  <table:table-cell table:style-name="ce1" office:value-type="string">
    <text:p><xsl:value-of select="."/></text:p>
  </table:table-cell>
</xsl:template>

</xsl:stylesheet>