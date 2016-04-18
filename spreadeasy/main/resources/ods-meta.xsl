<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions"
xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" xmlns:ooo="http://openoffice.org/2004/office" xmlns:grddl="http://www.w3.org/2003/g/data-view#"
>
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:template match="/">
    <office:document-meta office:version="1.2">
      <office:meta>
        <xsl:for-each select="SPREADSHEET/ROWSET[1]/ROW[1]">
          <meta:initial-creator><xsl:value-of select="Author"/></meta:initial-creator>
          <meta:creation-date><xsl:value-of select="substring-before(Created,'Z')"/></meta:creation-date>
          <dc:date><xsl:value-of select="substring-before(LastSaved,'Z')"/></dc:date>
          <dc:creator><xsl:value-of select="LastAuthor"/></dc:creator>
          <meta:generator><xsl:value-of select="Generator"/></meta:generator>
          <meta:editing-duration>PT1M1S</meta:editing-duration>
          <meta:editing-cycles><xsl:value-of select="Version"/></meta:editing-cycles>
          <meta:document-statistic>
            <xsl:attribute name="meta:table-count"><xsl:value-of select="count(//ROWSET[position()>1])"/></xsl:attribute>
            <xsl:attribute name="meta:cell-count"><xsl:value-of select="count(//ROWSET[position()>1]/ROW/*)"/></xsl:attribute>
            <xsl:attribute name="meta:object-count"><xsl:value-of select="count(//object)"/></xsl:attribute> <!-- always 0 -->
          </meta:document-statistic>
        </xsl:for-each>
      </office:meta>
    </office:document-meta>
  </xsl:template>

</xsl:stylesheet>