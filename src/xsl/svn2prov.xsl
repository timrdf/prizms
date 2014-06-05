<!--
#3> <> prov:specializationOf <https://github.com/timrdf/prizms/tree/master/src/xsl/svn2prov.xsl>;
#3>    prov:wasDerivedFrom <https://github.com/tetherless-world/opendap/blob/master/data/source/opendap-org/opendap/src/grddl.xsl>;
#3>    rdfs:seeAlso        <https://github.com/tetherless-world/opendap/wiki/SVN-Log-XML>,
#3>                        <https://github.com/timrdf/pvcs/wiki/svn2prov>,
#3>                        <https://github.com/tetherless-world/opendap/wiki/Modeling-VCS-with-PROV>;
#3> .
-->
<xsl:transform version="2.0" 
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   exclude-result-prefixes="">
<xsl:output method="text"/>

<xsl:param name="cr-base-uri"   select="'http://opendap.tw.rpi.edu'"/>
<xsl:param name="cr-source-id"  select="'opendap-org'"/>
<xsl:param name="cr-dataset-id" select="'opendap'"/>
<xsl:param name="cr-version-id" select="'svn'"/>

<xsl:param name="svn" select="''"/> <!-- e.g. https://scm.opendap.org/svn -->

<xsl:variable name="s"   select="concat($cr-base-uri,'/source/',$cr-source-id,'/')"/>
<xsl:variable name="sd"  select="concat($s, 'dataset/',$cr-dataset-id,'/')"/>
<xsl:variable name="sdv" select="concat($sd,'version/',$cr-version-id,'/')"/>
<xsl:variable name="sdv_" select="concat($sd,'version/',$cr-version-id)"/>


<xsl:variable name="prefixes"><xsl:text><![CDATA[@prefix prov:   <http://www.w3.org/ns/prov#>.
@prefix rdfs:   <http://www.w3.org/2000/01/rdf-schema#>.
@prefix xsd:    <http://www.w3.org/2001/XMLSchema#>.
@prefix schema: <http://schema.org/>.
@prefix prv:    <http://purl.org/net/provenance/ns#>.
@prefix nfo:    <http://www.semanticdesktop.org/ontologies/nfo/#>.
@prefix nif:    <http://persistence.uni-leipzig.org/nlp2rdf/ontologies/nif-core#>.
]]>
</xsl:text>
</xsl:variable>

<xsl:template match="/">
   <xsl:value-of select="$prefixes"/>

   <xsl:for-each-group select="log/logentry/paths/path" group-by="@kind">
      <xsl:message select="concat('kind: ',current-grouping-key())"/>
   </xsl:for-each-group>

   <xsl:for-each-group select="log/logentry" group-by="author">
      <xsl:message select="concat('author: ',current-grouping-key())"/>
   </xsl:for-each-group>

   <xsl:message select="concat('num no authors: ',count(log/logentry[not(author)]))"/>

   <xsl:for-each-group select="log/logentry/paths/path" group-by="@action">
      <xsl:message select="concat('action: ',current-grouping-key())"/>
   </xsl:for-each-group>

   <xsl:apply-templates select="//logentry">
      <xsl:sort select="number(@revision)" order="descending"/>
   </xsl:apply-templates>
</xsl:template>

<!--
   <logentry revision="27563">
      <author>hyoklee</author>
      <date>2013-12-18T18:56:14.764583Z</date>
      <paths>
         <path kind="" action="M">/trunk/hdf5_handler/data.nasa/download.sh</path>
      </paths>
      <msg>added support for symbolic linked NASA files.</msg>
   </logentry>
-->

<xsl:template match="logentry">
   <xsl:value-of select="concat('&lt;',$sdv,'commit/',@revision,'&gt;',$NL,
                                '   #pvcs:Commit;',$NL,
                                '   a prov:Activity;',$NL)"/>

   <xsl:if test="string-length(author/text())">
      <xsl:value-of select="concat('   prov:wasAttributedTo &lt;',$s,'id/developer/',author,'&gt;;',$NL)"/>
   </xsl:if>

   <xsl:if test="string-length(date/text())">
      <xsl:value-of select="concat('   prov:endedAtTime ',$DQ,date,$DQ,'^^xsd:dateTime;',$NL)"/>
   </xsl:if>

   <xsl:if test="matches(@revision,'^[0-9]+$')">
      <xsl:value-of select="concat('   prov:wasInformedBy &lt;',$sdv,'commit/',number(@revision)-1,'&gt;;',$NL)"/>
   </xsl:if>

   <!-- paths -->
   <xsl:for-each select="paths/path[not(contains(.,'&gt;'))]">
      <xsl:variable name="path"     select="replace(.,' ','%20')"/>
      <xsl:variable name="revision" select="concat('&lt;',$sdv,'revision/',../../@revision,$path,'&gt;')"/>
      <xsl:value-of select="concat('   prov:generated ',$revision,';',$NL)"/>
   </xsl:for-each>

   <xsl:if test="string-length(msg/text())">
      <xsl:value-of select="concat('   rdfs:comment ',$DQ,$DQ,$DQ,replace(replace(msg,'\\', '\\\\'),
                                                                          $DQ, concat('\\',$DQ)),
                                                      $DQ,$DQ,$DQ,';',$NL)"/>
   </xsl:if>

   <xsl:value-of select="concat('.',$NL)"/>

   <!-- paths -->
   <xsl:for-each select="paths/path[not(contains(.,'&gt;'))]">
      <xsl:variable name="path"         select="replace(.,' ','%20')"/>
      <xsl:variable name="revisionless" select="concat('&lt;',$sdv_,                            $path,'&gt;')"/>
      <xsl:variable name="revision"     select="concat('&lt;',$sdv, 'revision/',../../@revision,$path,'&gt;')"/>
      <xsl:value-of select="concat($NL,$revision,$NL,
                                   '   a prv:Immutable, nif:String, prov:Entity;',$NL,
                                   '   schema:version ',$DQ,../../@revision,$DQ,';',$NL,
                                   '   #prov:value __contents of the file__',$NL,
                                   '   #pvcs:hasHash [ nfo:hashAlgorithm, nfo:hashValue ];')"/>
      <!-- TODO: 2012-09-05T20:21:54.521200Z 
         @copyfrom-rev @copyfrom-path
        -->
      <xsl:if test="@copyfrom-rev and @copyfrom-path">
         <xsl:variable name="antecedent" select="concat('&lt;',$sdv,'revision/',@copyfrom-rev,replace(@copyfrom-path,' ','%20'),'&gt;')"/>
         <xsl:value-of select="concat($NL,'   prov:wasDerivedFrom ',$antecedent,';')"/>
      </xsl:if>
      <xsl:variable name="no-svn" select="if(string-length($svn)) then '' else '# parameter *svn* missing...'"/>
      <xsl:value-of select="concat($NL,'   prov:specializationOf ',$revisionless,';',$NL,
                                   '.',$NL,
                                   $revisionless,$NL,
                                   '   #a pvcs:Mutable;',$NL,
                                   '   a  nfo:FileDataObject, prov:Entity;',$NL,
                                   $no-svn,'   nfo:fileName     ',replace($svn,'.',' '),$DQ,$path,$DQ,';',$NL,
                                   $no-svn,'   prv:serializedBy &lt;',$svn,$path,'&gt;;',$NL,
                                   $no-svn,'   nfo:fileURL      &lt;',$svn,$path,'&gt;;',$NL,
                                   '.')"/>
   </xsl:for-each>

   <xsl:value-of select="concat($NL,$NL,'# ^ ^ - - ',@revision,' - - ^ ^',$NL,$NL)"/>
</xsl:template>

<xsl:template match="@*|node()">
  <xsl:copy>
      <xsl:copy-of select="@*"/>   
      <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

<!--xsl:template match="text()">
   <xsl:value-of select="normalize-space(.)"/>
</xsl:template-->

<xsl:variable name="NL" select="'&#xa;'"/>
<xsl:variable name="DQ" select="'&#x22;'"/>

</xsl:transform>
