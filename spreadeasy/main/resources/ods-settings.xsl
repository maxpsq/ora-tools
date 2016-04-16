<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:config="urn:oasis:names:tc:opendocument:xmlns:config:1.0" 
  xmlns:ooo="http://openoffice.org/2004/office">

  <xsl:template match="/">
    <office:document-settings office:version="1.2">
      <office:settings>
        <config:config-item-set config:name="ooo:view-settings">
          <config:config-item config:name="VisibleAreaTop" config:type="int">0</config:config-item>
          <config:config-item config:name="VisibleAreaLeft" config:type="int">0</config:config-item>
          <config:config-item config:name="VisibleAreaWidth" config:type="int">10536</config:config-item>
          <config:config-item config:name="VisibleAreaHeight" config:type="int">1291</config:config-item>
          <config:config-item-map-indexed config:name="Views">
            <config:config-item-map-entry>
              <config:config-item config:name="ViewId" config:type="string">view1</config:config-item>
              <config:config-item-map-named config:name="Tables">

                <xsl:apply-templates/>

              </config:config-item-map-named>
              <config:config-item config:name="ActiveTable" config:type="string"><xsl:value-of select="node()/ROWSET/@worksheet_name"/></config:config-item>
              <config:config-item config:name="HorizontalScrollbarWidth" config:type="int">270</config:config-item>
              <config:config-item config:name="ZoomType" config:type="short">0</config:config-item>
              <config:config-item config:name="ZoomValue" config:type="int">85</config:config-item>
              <config:config-item config:name="PageViewZoomValue" config:type="int">60</config:config-item>
              <config:config-item config:name="ShowPageBreakPreview" config:type="boolean">false</config:config-item>
              <config:config-item config:name="ShowZeroValues" config:type="boolean">true</config:config-item>
              <config:config-item config:name="ShowNotes" config:type="boolean">true</config:config-item>
              <config:config-item config:name="ShowGrid" config:type="boolean">true</config:config-item>
              <config:config-item config:name="GridColor" config:type="long">12632256</config:config-item>
              <config:config-item config:name="ShowPageBreaks" config:type="boolean">true</config:config-item>
              <config:config-item config:name="HasColumnRowHeaders" config:type="boolean">true</config:config-item>
              <config:config-item config:name="HasSheetTabs" config:type="boolean">true</config:config-item>
              <config:config-item config:name="IsOutlineSymbolsSet" config:type="boolean">true</config:config-item>
              <config:config-item config:name="IsSnapToRaster" config:type="boolean">false</config:config-item>
              <config:config-item config:name="RasterIsVisible" config:type="boolean">false</config:config-item>
              <config:config-item config:name="RasterResolutionX" config:type="int">1000</config:config-item>
              <config:config-item config:name="RasterResolutionY" config:type="int">1000</config:config-item>
              <config:config-item config:name="RasterSubdivisionX" config:type="int">1</config:config-item>
              <config:config-item config:name="RasterSubdivisionY" config:type="int">1</config:config-item>
              <config:config-item config:name="IsRasterAxisSynchronized" config:type="boolean">true</config:config-item>
            </config:config-item-map-entry>
          </config:config-item-map-indexed>
        </config:config-item-set>
        <config:config-item-set config:name="ooo:configuration-settings">
          <config:config-item config:name="ShowZeroValues" config:type="boolean">true</config:config-item>
          <config:config-item config:name="IsOutlineSymbolsSet" config:type="boolean">true</config:config-item>
          <config:config-item config:name="ShowGrid" config:type="boolean">true</config:config-item>
          <config:config-item config:name="ShowNotes" config:type="boolean">true</config:config-item>
          <config:config-item config:name="ShowPageBreaks" config:type="boolean">true</config:config-item>
          <config:config-item config:name="IsRasterAxisSynchronized" config:type="boolean">true</config:config-item>
          <config:config-item config:name="HasSheetTabs" config:type="boolean">true</config:config-item>
          <config:config-item config:name="IsSnapToRaster" config:type="boolean">false</config:config-item>
          <config:config-item config:name="PrinterName" config:type="string"/>
          <config:config-item config:name="SaveVersionOnClose" config:type="boolean">false</config:config-item>
          <config:config-item config:name="GridColor" config:type="long">12632256</config:config-item>
          <config:config-item config:name="RasterIsVisible" config:type="boolean">false</config:config-item>
          <config:config-item config:name="RasterSubdivisionX" config:type="int">1</config:config-item>
          <config:config-item config:name="LinkUpdateMode" config:type="short">3</config:config-item>
          <config:config-item config:name="RasterResolutionY" config:type="int">1000</config:config-item>
          <config:config-item config:name="HasColumnRowHeaders" config:type="boolean">true</config:config-item>
          <config:config-item config:name="RasterSubdivisionY" config:type="int">1</config:config-item>
          <config:config-item config:name="PrinterSetup" config:type="base64Binary"/>
          <config:config-item config:name="ApplyUserData" config:type="boolean">true</config:config-item>
          <config:config-item config:name="AutoCalculate" config:type="boolean">true</config:config-item>
          <config:config-item config:name="IsKernAsianPunctuation" config:type="boolean">false</config:config-item>
          <config:config-item config:name="RasterResolutionX" config:type="int">1000</config:config-item>
          <config:config-item config:name="LoadReadonly" config:type="boolean">false</config:config-item>
          <config:config-item config:name="IsDocumentShared" config:type="boolean">false</config:config-item>
          <config:config-item config:name="AllowPrintJobCancel" config:type="boolean">true</config:config-item>
          <config:config-item config:name="UpdateFromTemplate" config:type="boolean">true</config:config-item>
          <config:config-item config:name="CharacterCompressionType" config:type="short">0</config:config-item>
        </config:config-item-set>
      </office:settings>
    </office:document-settings>

  </xsl:template>


  <xsl:template match="/*/*[position() = 1]">
  </xsl:template>


  <xsl:template match="/*/*[position() > 1]">
    <config:config-item-map-entry><xsl:attribute name="config:name"/><xsl:value-of select="@worksheet_name"/>
      <config:config-item config:name="CursorPositionX" config:type="int">0</config:config-item>
      <config:config-item config:name="CursorPositionY" config:type="int">0</config:config-item>
      <config:config-item config:name="HorizontalSplitMode" config:type="short">0</config:config-item>
      <config:config-item config:name="VerticalSplitMode" config:type="short">0</config:config-item>
      <config:config-item config:name="HorizontalSplitPosition" config:type="int">0</config:config-item>
      <config:config-item config:name="VerticalSplitPosition" config:type="int">0</config:config-item>
      <config:config-item config:name="ActiveSplitRange" config:type="short">2</config:config-item>
      <config:config-item config:name="PositionLeft" config:type="int">0</config:config-item>
      <config:config-item config:name="PositionRight" config:type="int">0</config:config-item>
      <config:config-item config:name="PositionTop" config:type="int">0</config:config-item>
      <config:config-item config:name="PositionBottom" config:type="int">0</config:config-item>
      <config:config-item config:name="ZoomType" config:type="short">0</config:config-item>
      <config:config-item config:name="ZoomValue" config:type="int">85</config:config-item>
      <config:config-item config:name="PageViewZoomValue" config:type="int">60</config:config-item>
    </config:config-item-map-entry>
  </xsl:template>

</xsl:stylesheet>