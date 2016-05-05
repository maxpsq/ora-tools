<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions"
xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0" xmlns:presentation="urn:oasis:names:tc:opendocument:xmlns:presentation:1.0" xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0" xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0" xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0" xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0" xmlns:ooo="http://openoffice.org/2004/office" xmlns:ooow="http://openoffice.org/2004/writer" xmlns:oooc="http://openoffice.org/2004/calc" xmlns:dom="http://www.w3.org/2001/xml-events" xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:rpt="http://openoffice.org/2005/report" xmlns:of="urn:oasis:names:tc:opendocument:xmlns:of:1.2" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:grddl="http://www.w3.org/2003/g/data-view#" xmlns:tableooo="http://openoffice.org/2009/table" xmlns:field="urn:openoffice:names:experimental:ooo-ms-interop:xmlns:field:1.0" office-version="1.2"> 

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

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
          <style:table-row-properties style:row-height="0.42cm" fo:break-before="auto" style:use-optimal-row-height="true" />
        </style:style>
        <style:style style:name="ta1" style:family="table" style:master-page-name="Default">
          <style:table-properties table:display="true">
            <xsl:attribute name="style:writing-mode"><xsl:value-of select="/SPREADSHEET/LOCALE/WRITING_MODE"/></xsl:attribute>
          </style:table-properties>
        </style:style>
        <number:date-style style:name="N37" number:automatic-order="true">
          <xsl:call-template name="analyze-date-format">
            <xsl:with-param name="p-date-format" select="/SPREADSHEET/LOCALE/DATE_FORMAT" />
          </xsl:call-template>
        </number:date-style>
        <number:date-style style:name="N38" number:automatic-order="true">
          <xsl:call-template name="analyze-date-format">
            <xsl:with-param name="p-date-format" select="/SPREADSHEET/LOCALE/DATE_FORMAT" />
          </xsl:call-template>
          <number:text xml:space="preserve"> </number:text>
          <xsl:call-template name="analyze-time-format">
            <xsl:with-param name="p-time-format" select="/SPREADSHEET/LOCALE/TIME_FORMAT" />
          </xsl:call-template>
        </number:date-style>
        <number:number-style style:name="N8000">
          <xsl:attribute name="number:language"><xsl:value-of select="/SPREADSHEET/LOCALE/LANGUAGE"/></xsl:attribute>
          <xsl:attribute name="number:country"><xsl:value-of select="/SPREADSHEET/LOCALE/TERRITORY"/></xsl:attribute>
          <number:number number:min-integer-digits="1" />
        </number:number-style>
        <style:style style:name="ce1" style:family="table-cell" style:parent-style-name="Default" style:data-style-name="N8000" />
        <style:style style:name="ce2" style:family="table-cell" style:parent-style-name="Default" style:data-style-name="N37" />
        <style:style style:name="ce3" style:family="table-cell" style:parent-style-name="Default" style:data-style-name="N38" />
      </office:automatic-styles>
      <office:body>
        <office:spreadsheet>
          <xsl:apply-templates/>
        </office:spreadsheet>
      </office:body>
    </office:document-content>
  </xsl:template>


  <xsl:template match="/*/LOCALE">
  </xsl:template>


  <xsl:template match="/*/*[position() = 2]">
  </xsl:template>


  <xsl:template match="/*/*[position() > 2]">
    <table:table table:style-name="ta1" table:print="false">
      <xsl:attribute name="table:name"><xsl:value-of select="./@worksheet_name"/></xsl:attribute>
      <table:table-column table:style-name="co1" table:default-cell-style-name="Default" />
      <table:table-row table:style-name="ro1">
      <xsl:for-each select="*[position() = 1]/*">
         <table:table-cell table:style-name="Default" office:value-type="string">
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


  <xsl:template match="/*/*[position() > 1]/*/*[@oratype='DATE' and contains(text(),'T00:00:00.000')]">
    <table:table-cell table:style-name="ce2" office:value-type="date">
      <xsl:attribute name="office:date-value"><xsl:value-of select="substring-before(.,'T00:00:00.000')"/></xsl:attribute>
      <text:p>
          <xsl:call-template name="format-datetime">
            <xsl:with-param name="p-datetime-value" select="substring-before(.,'T00:00:00.000')" /> 
            <xsl:with-param name="p-datetime-format" select="/SPREADSHEET/LOCALE/DATE_FORMAT" />
          </xsl:call-template>
      </text:p>
    </table:table-cell>
  </xsl:template>


  <xsl:template match="/*/*[position() > 1]/*/*[@oratype='DATE' and not(contains(text(),'T00:00:00.000'))]">
    <table:table-cell table:style-name="ce3" office:value-type="date">
      <xsl:attribute name="office:date-value"><xsl:value-of select="substring-before(.,'.000')"/></xsl:attribute>
      <text:p>
          <xsl:call-template name="format-datetime">
            <xsl:with-param name="p-datetime-value" select="substring-before(.,'.000')" /> 
            <xsl:with-param name="p-datetime-format" select="/SPREADSHEET/LOCALE/DATETIME_FORMAT" />
          </xsl:call-template>
      </text:p>
    </table:table-cell>
  </xsl:template>


  
  <xsl:template match="/*/*[position() > 1]/*/*[@oratype='TIMESTAMP' or @oratype='TIMESTAMP WITH TIME ZONE' or @oratype='TIMESTAMP WITH LOCAL TIMEZONE']">
    <table:table-cell table:style-name="ce3" office:value-type="date">
      <xsl:attribute name="office:date-value"><xsl:value-of select="substring-before(.,'.000')"/></xsl:attribute>  
      <text:p>
          <xsl:call-template name="format-datetime">
            <xsl:with-param name="p-datetime-value" select="substring-before(.,'.000')" /> 
            <xsl:with-param name="p-datetime-format" select="/SPREADSHEET/LOCALE/DATETIME_FORMAT" />
          </xsl:call-template>
      </text:p>
    </table:table-cell>
  </xsl:template>

  <!-- ODS supports up to 11 decimal positions, then no particular actions on numbers within this precision -->
  <!-- Notice "<=" was replaced with "&lt;=" in order to avoid errors while parsing this document -->
  <xsl:template match="/*/*[position() > 1]/*/*[@sstype='Numeric' and string-length(substring-after(., '.')) &lt;= 11]">
    <table:table-cell office:value-type="float">
      <xsl:attribute name="office:value"><xsl:value-of select="."/></xsl:attribute>
      <text:p><xsl:value-of select="."/></text:p>
    </table:table-cell>
  </xsl:template>

  <!-- ODS supports up to 11 decimal positions, then we need to round the numbers over this precision -->
  <!-- Notice ">" was replaced with "&gt;" in order to avoid errors while parsing this document -->
  <xsl:template match="/*/*[position() > 1]/*/*[@sstype='Numeric' and string-length(substring-after(., '.')) &gt; 11]">
    <table:table-cell office:value-type="float">
      <xsl:attribute name="office:value"><xsl:value-of select="format-number(.,'#.###########')"/></xsl:attribute>
      <text:p><xsl:value-of select="format-number(.,'#.###########')"/></text:p>
    </table:table-cell>
  </xsl:template>


  <xsl:template match="/*/*[position() > 1]/*/*[@sstype='String']">
    <table:table-cell office:value-type="string">
      <text:p><xsl:value-of select="."/></text:p>
    </table:table-cell>
  </xsl:template>


  <xsl:template name="analyze-date-format">
    <xsl:param name="p-date-format"/>
    <xsl:variable name="date-format" select="translate($p-date-format, 'yrmd', 'YRMD')" />
    <xsl:variable name="separators" select="translate($date-format, 'YRMD', '')" />
    <xsl:variable name="separator" select="substring($separators, 1, 1)" />
    <xsl:variable name="token">
        <xsl:choose>
            <xsl:when test="$separator">
                <xsl:value-of select="substring-before($date-format, $separator)" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$date-format" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:choose>
        <xsl:when test="$token = 'YYYY'">
            <number:year number:style="long" />
        </xsl:when>
        <xsl:when test="$token = 'RRRR'">
            <number:year number:style="long" />
        </xsl:when>
        <xsl:when test="$token = 'YY'">
            <number:year number:style="short" />
        </xsl:when>
        <xsl:when test="$token = 'RR'">
            <number:year number:style="short" />
        </xsl:when>
        <xsl:when test="$token = 'MM'">
            <number:month number:style="long" />
        </xsl:when>
        <xsl:when test="$token = 'DD'">
            <number:day number:style="long" />
        </xsl:when>
    </xsl:choose> 
    <xsl:if test="$separators">
      <!-- DO NOT BREAKE THIS LINE!! Notice xml:space="preserve" -->
        <number:text xml:space="preserve"><xsl:value-of select="$separator" /></number:text>
         <!-- recursive call -->
        <xsl:call-template name="analyze-date-format">
            <xsl:with-param name="p-date-format" select="substring-after($date-format, $separator)" />
        </xsl:call-template>
    </xsl:if>
  </xsl:template>

  
  <xsl:template name="analyze-time-format">
    <xsl:param name="p-time-format"/>
    <xsl:variable name="time-format" select="translate($p-time-format, 'hmis', 'HMIS')" />
    <xsl:variable name="separators" select="translate($time-format, 'H24MIS', '')" />
    <xsl:variable name="separator" select="substring($separators, 1, 1)" />
    <xsl:variable name="token">
        <xsl:choose>
            <xsl:when test="$separator">
                <xsl:value-of select="substring-before($time-format, $separator)" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$time-format" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:choose>
        <xsl:when test="$token = 'HH24'">
            <number:hours number:style="long" />
        </xsl:when>
        <xsl:when test="$token = 'HH'">
            <number:hours number:style="long" />
        </xsl:when>
        <xsl:when test="$token = 'MI'">
            <number:minutes number:style="long" />
        </xsl:when>
        <xsl:when test="$token = 'SS'">
            <number:seconds number:style="long" />
        </xsl:when>
    </xsl:choose> 
    <xsl:if test="$separators">
      <!-- DO NOT BREAKE THIS LINE!! Notice xml:space="preserve" -->
        <number:text xml:space="preserve"><xsl:value-of select="$separator" /></number:text>
         <!-- recursive call -->
        <xsl:call-template name="analyze-time-format">
            <xsl:with-param name="p-time-format" select="substring-after($time-format, $separator)" />
        </xsl:call-template>
    </xsl:if>
  </xsl:template>



  <xsl:template name="format-datetime">
    <xsl:param name="p-datetime-value"/>
    <xsl:param name="p-datetime-format"/>
    <xsl:variable name="datetime-format" select="translate($p-datetime-format, 'yrmdhis', 'YRMDHIS')" /> 
    <xsl:variable name="separators" select="translate($datetime-format, 'YRMDH24IS', '')" />
    <xsl:variable name="separator" select="substring($separators, 1, 1)" />
    <xsl:variable name="year" select="substring($p-datetime-value,  1, 4)" />
    <xsl:variable name="month" select="substring($p-datetime-value,  6, 2)" />
    <xsl:variable name="day" select="substring($p-datetime-value,  9, 2)" />
    <xsl:variable name="hour" select="substring($p-datetime-value,  12, 2)" />
    <xsl:variable name="min" select="substring($p-datetime-value,  15, 2)" />
    <xsl:variable name="sec" select="substring($p-datetime-value,  18, 2)" />
  
    <xsl:variable name="token">
        <xsl:choose>
            <xsl:when test="$separator">
                <xsl:value-of select="substring-before($datetime-format, $separator)" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$datetime-format" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:choose>
        <xsl:when test="$token = 'YYYY'">
            <xsl:value-of select="$year" />
        </xsl:when>
        <xsl:when test="$token = 'RRRR'">
            <xsl:value-of select="$year" />
        </xsl:when>
        <xsl:when test="$token = 'YY'">
            <xsl:value-of select="substring($year,3,2)" />
        </xsl:when>
        <xsl:when test="$token = 'RR'">
            <xsl:value-of select="substring($year,3,2)" />
        </xsl:when>
        <xsl:when test="$token = 'MM'">
            <xsl:value-of select="$month" />
        </xsl:when>
        <xsl:when test="$token = 'DD'">
            <xsl:value-of select="$day" />
        </xsl:when>
        <xsl:when test="$token = 'HH'">
            <xsl:value-of select="$hour" />
        </xsl:when>
        <xsl:when test="$token = 'HH24'">
            <xsl:value-of select="$hour" />
        </xsl:when>
        <xsl:when test="$token = 'MI'">
            <xsl:value-of select="$min" />
        </xsl:when>
        <xsl:when test="$token = 'SS'">
            <xsl:value-of select="$sec" />
        </xsl:when>
    </xsl:choose> 
    <xsl:if test="$separators">
        <xsl:value-of select="$separator" />
         <!-- recursive call -->
        <xsl:call-template name="format-datetime">
            <xsl:with-param name="p-datetime-value"  select="$p-datetime-value" />
            <xsl:with-param name="p-datetime-format" select="substring-after($datetime-format, $separator)" />
        </xsl:call-template>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>