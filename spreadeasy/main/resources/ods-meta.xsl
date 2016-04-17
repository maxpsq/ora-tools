<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions"
xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" xmlns:ooo="http://openoffice.org/2004/office" xmlns:grddl="http://www.w3.org/2003/g/data-view#">

  <xsl:output method="xml" indent="yes" encoding="utf-8"/>

  <xsl:template match="/SPREADSHEET/ROWSET[position()=1]/ROW">
    <office:document-meta office:version="1.2">
      <office:meta>
        <meta:initial-creator><xsl:value-of select="Author"/></meta:initial-creator>
        <meta:creation-date><xsl:value-of select="substring-before(./Created,'Z')"/></meta:creation-date>
        <dc:date><xsl:value-of select="substring-before(./LastSaved,'Z')"/></dc:date>
        <dc:creator><xsl:value-of select="./LastAuthor"/></dc:creator>
        <meta:generator><xsl:value-of select="./Generator"/></meta:generator>
        <meta:editing-cycles><xsl:value-of select="./Version"/></meta:editing-cycles>
      </office:meta>
    </office:document-meta>
  </xsl:template>

  <xsl:template match="/*/*/*"></xsl:template>

</xsl:stylesheet>