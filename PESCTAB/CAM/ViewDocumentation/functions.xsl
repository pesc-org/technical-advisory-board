<xsl:function name="as-xsl:getDefaultValue">
        <xsl:param name="datatype"/>
        <xsl:param name="optional"/>
        <xsl:param name="xpath"/>
        
        <xsl:variable name="default">
            <xsl:choose>
                <xsl:when test="$rules/Rule[ends-with(@xpath,$xpath)][@type = 'setDefault']">
                    <xsl:variable name="defaultValue" select="$rules/Rule[ends-with(@xpath,$xpath)][@type = 'setDefault']/@value"/>
                    <xsl:value-of select="$defaultValue[1]"/>
                </xsl:when>
                <xsl:when test="$rules/Rule[ends-with(@xpath,$xpath)][@type = 'list']">
                    <xsl:variable name="defaultValue" select="as-xsl:setENUMdefault($xpath)"/>
                    <xsl:value-of select="$defaultValue[1]"/>
                </xsl:when>
                <xsl:when test="$datatype = 'boolean'">0</xsl:when>
                <xsl:when test="$datatype = 'date'">0000-00-00</xsl:when>
                <xsl:when test="$datatype = 'time'">00:00:00</xsl:when>
                <xsl:when test="$rules/Rule[ends-with(@xpath,$xpath)][@type='number']">
                    <xsl:variable name="mask" select="$rules/Rule[ends-with(@xpath,$xpath)][@type='number']/@mask" />
                    <xsl:choose>
                        <xsl:when test="contains($mask[1],'.')">0.0</xsl:when>
                        <xsl:otherwise>0</xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="' '"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$descriptions/Key[contains(@xpath,$xpath)]"/><!-- Do not assign null value if key column -->
            <xsl:when test="$rules/Rule[ends-with(@xpath,$xpath)][@type = 'setDefault']">DEFAULT '<xsl:value-of select="$default"/>'</xsl:when>
            <xsl:when test="$rules/Rule[ends-with(@xpath,$xpath)][@type = 'list']">DEFAULT <xsl:value-of select="if(string-length($default) &gt; 0) then $default else 'NULL'"/></xsl:when>
            <xsl:when test="$optional">DEFAULT NULL</xsl:when>
            <xsl:when test="$datatype = 'boolean'">DEFAULT '<xsl:value-of select="$default"/>'</xsl:when>
            <xsl:when test="$datatype = 'date'">DEFAULT '<xsl:value-of select="$default"/>'</xsl:when>
            <xsl:when test="starts-with($datatype,'char(')">DEFAULT '<xsl:value-of select="$default"/>'</xsl:when>
            <xsl:when test="starts-with($datatype,'int(')">DEFAULT '<xsl:value-of select="$default"/>'</xsl:when>
            <xsl:when test="starts-with($datatype,'decimal(')">DEFAULT '<xsl:value-of select="$default"/>'</xsl:when>
            <xsl:when test="starts-with($datatype,'float(')">DEFAULT '<xsl:value-of select="$default"/>'</xsl:when>
            <xsl:when test="starts-with($datatype,'number(')">DEFAULT '<xsl:value-of select="$default"/>'</xsl:when>
            <xsl:otherwise>DEFAULT ''</xsl:otherwise>
        </xsl:choose>
    </xsl:function> 
    <xsl:function name="as-xsl:parseNumberMask">
        <xsl:param name="mask"/>
        <xsl:choose>
            <xsl:when test="contains($mask,'.')">
                <xsl:value-of select="concat(string-length(normalize-space(substring-before($mask,'.'))),'.',string-length(normalize-space(substring-after($mask,'.'))))"/>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="string-length(normalize-space($mask))"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="as-xsl:setENUMvalues">
        <xsl:param name="xpath"/>
        <xsl:param name="datatype"/>
        <xsl:choose>
        <xsl:when test="$rules/Rule[ends-with(@xpath,$xpath)][@type='list']">
            <xsl:variable name="enumValuesMask" select="$rules/Rule[ends-with(@xpath,$xpath)][@type='list']/@values"/>
            <xsl:variable name="enumDefault" select="substring-after($enumValuesMask[1],',')"/>
            <xsl:variable name="enumValues" select="if(string-length($enumDefault) &gt; 0) then substring-before($enumValuesMask[1],',') else $enumValuesMask[1]"/>
            <xsl:variable name="outputENUM"><xsl:text>ENUM(</xsl:text><xsl:value-of select="replace($enumValues[1],'\|',''',''')"/><xsl:text>) </xsl:text></xsl:variable>
            <xsl:value-of select="$outputENUM"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="$datatype"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="as-xsl:setENUMdefault">
        <xsl:param name="xpath"/>
        <xsl:if test="$rules/Rule[ends-with(@xpath,$xpath)][@type='list']">
            <xsl:variable name="enumValuesMask" select="$rules/Rule[ends-with(@xpath,$xpath)][@type='list']/@values"/>
            <xsl:variable name="enumDefault" select="substring-after($enumValuesMask[1],',')"/>
            <xsl:value-of select="$enumDefault"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="as-xsl:getFieldDefinition">
        <xsl:param name="ParentName"/>
        <xsl:param name="ElementName"/>
        <xsl:variable name="thisXPath" select="concat('/',$ParentName,'/',$ElementName)"/>
        <xsl:variable name="setLength">
            <xsl:variable name="length" select="$rules/Rule[ends-with(@xpath,$thisXPath)][@type='length']/@value"/>
            <xsl:value-of select="if(contains($length[1],'-')) then substring-after($length[1],'-') else $length[1]"/>
        </xsl:variable>
        <xsl:variable name="datatype">
            <xsl:variable name="listItemLength" select="if(string-length($setLength) = 0) then '255' else $setLength"/>
            <xsl:choose>
                <xsl:when test="$rules/Rule[ends-with(@xpath,$thisXPath)][@type='boolean']">boolean</xsl:when>
                <xsl:when test="$rules/Rule[ends-with(@xpath,$thisXPath)][@type='list']"><xsl:value-of select="if($listItemLength = '1') then 'char' else 'varchar'"></xsl:value-of>(<xsl:value-of select="$listItemLength"/>)</xsl:when>
                <xsl:when test="$rules/Rule[ends-with(@xpath,$thisXPath)][@type='datetype']">
                    <xsl:variable name="mask" select="$rules/Rule[ends-with(@xpath,$thisXPath)][@type='datetype']/@mask" />
                    <xsl:choose>
                        <xsl:when test="$mask[1] = 'datetime'">datetime</xsl:when>
                        <xsl:when test="contains($mask[1],':') and(contains($mask[1],'-'))">datetime</xsl:when>
                        <xsl:when test="contains($mask[1],':')">time</xsl:when>
                        <xsl:otherwise>date</xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$rules/Rule[ends-with(@xpath,$thisXPath)][@type='number']">
                    <xsl:variable name="mask" select="$rules/Rule[ends-with(@xpath,$thisXPath)][@type='number']/@mask" />
                    <xsl:variable name="mask-value" select="as-xsl:parseNumberMask($mask)"/>
                    <xsl:choose>
                        <xsl:when test="contains($mask,'.')">float(<xsl:value-of select="$mask-value"/>)</xsl:when>
                        <xsl:when test="string-length($setLength) &gt; 0">int(<xsl:value-of select="$setLength"/>)</xsl:when>
                        <xsl:otherwise>int(<xsl:value-of select="$mask-value"/>)</xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="string-length($setLength) &gt; 0">
                    <xsl:value-of select="if($setLength = '1') then 'char(1)' else concat('varchar(',$setLength,')')"/>
                </xsl:when>
                <xsl:otherwise>varchar(255)</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="required">
            <xsl:choose>
                <xsl:when test="$rules/Rule[ends-with(@xpath,$thisXPath)][@type='optional']"/> 
                <xsl:otherwise>NOT NULL </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>                       
        <xsl:variable name="optional" select="if($rules/Rule[ends-with(@xpath,$thisXPath)][@type='optional']) then true() else false()"/>
        <xsl:variable name="datatypeValues" select="as-xsl:setENUMvalues($thisXPath,$datatype)"/>
        <!-- xsl:text>`</xsl:text><xsl:value-of select="concat(as-xsl:getColumnName($ParentName,$ElementName),'` ',$datatypeValues,' ')"/><xsl:value-of select="$required"/> <xsl:value-of select="as-xsl:getDefaultValue($datatype,$optional,$thisXPath)"/ -->
        <xsl:value-of select="as-xsl:getColumnName($ParentName,$ElementName)"/>
    </xsl:function>

   <xsl:function name="as-xsl:getFieldDataTypeHTML">
        <xsl:param name="ParentName"/>
        <xsl:param name="ElementName"/>
        <xsl:variable name="thisXPath" select="concat('/',$ParentName,'/',$ElementName)"/>
        <xsl:variable name="setLength">
            <xsl:variable name="length" select="$rules/Rule[ends-with(@xpath,$thisXPath)][@type='length']/@value"/>
            <xsl:choose>
                <xsl:when test="string-length($length[1]) &gt; 0"><xsl:value-of select="if(contains($length[1],'-')) then substring-after($length[1],'-') else $length[1]"/></xsl:when>
                <xsl:otherwise>50</xsl:otherwise>
            </xsl:choose>
            
        </xsl:variable>
        <xsl:variable name="datatype">
            <xsl:variable name="listItemLength" select="if(string-length($setLength) = 0) then '60' else $setLength"/>
            <xsl:choose>
                <xsl:when test="$rules/Rule[ends-with(@xpath,$thisXPath)][@type='boolean']">boolean,1</xsl:when>
                <xsl:when test="$rules/Rule[ends-with(@xpath,$thisXPath)][@type='list']"><xsl:value-of select="if($listItemLength = '1') then 'text' else 'list'"></xsl:value-of>,<xsl:value-of select="$listItemLength"/></xsl:when>
                <xsl:when test="$rules/Rule[ends-with(@xpath,$thisXPath)][@type='datetype']">
                    <xsl:variable name="mask" select="$rules/Rule[ends-with(@xpath,$thisXPath)][@type='datetype']/@mask" />
                    <xsl:choose>
                        <xsl:when test="$mask[1] = 'datetime'">datetime,20</xsl:when>
                        <xsl:when test="contains($mask[1],':') and(contains($mask[1],'-'))">datetime,20</xsl:when>
                        <xsl:when test="contains($mask[1],':')">time,8</xsl:when>
                        <xsl:otherwise>date,10</xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$rules/Rule[ends-with(@xpath,$thisXPath)][@type='number']">
                    <xsl:variable name="mask" select="$rules/Rule[ends-with(@xpath,$thisXPath)][@type='number']/@mask" />
                    <xsl:variable name="mask-value" select="as-xsl:parseNumberMask($mask)"/>
                    <xsl:choose>
                        <xsl:when test="contains($mask,'.')">float,<xsl:value-of select="$setLength"/></xsl:when>
                        <xsl:when test="$setLength = '50'">integer,5</xsl:when>
                        <xsl:when test="$setLength = '255'">integer,5</xsl:when>
                        <xsl:when test="string-length($setLength) &gt; 0">integer,<xsl:value-of select="$setLength"/></xsl:when>
                        <xsl:otherwise>integer,5</xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$rules/Rule[ends-with(@xpath,$thisXPath)][@type='length'] and($setLength = '255')">text,70</xsl:when>
                <xsl:when test="$rules/Rule[ends-with(@xpath,$thisXPath)][@type='length']">text,<xsl:value-of select="if(xsd:integer($setLength) &gt; 70) then '70' else $setLength"/></xsl:when>
                <xsl:otherwise>text,70</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="required">
            <xsl:choose>
                <xsl:when test="$rules/Rule[ends-with(@xpath,$thisXPath)][@type='optional']"/> 
                <xsl:otherwise>NOT NULL </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>                       
        <xsl:variable name="optional" select="if($rules/Rule[ends-with(@xpath,$thisXPath)][@type='optional']) then true() else false()"/>
        <xsl:variable name="datatypeValues" select="as-xsl:setENUMvalues($thisXPath,$datatype)"/>
        <!-- xsl:text>`</xsl:text><xsl:value-of select="concat(as-xsl:getColumnName($ParentName,$ElementName),'` ',$datatypeValues,' ')"/><xsl:value-of select="$required"/> <xsl:value-of select="as-xsl:getDefaultValue($datatype,$optional,$thisXPath)"/ -->
        <!-- xsl:message> <xsl:value-of select="$thisXPath"/> - <xsl:value-of select="concat($datatype,',',if($optional) then 'optional' else 'required')"/></xsl:message -->
        <xsl:value-of select="concat($datatype,',',if($optional) then 'optional' else 'required')"/>
    </xsl:function>
   <xsl:function name="as-xsl:getFieldValues">
        <xsl:param name="ParentName"/>
        <xsl:param name="ElementName"/>
        <xsl:variable name="thisXPath" select="concat('/',$ParentName,'/',$ElementName)"/>
        <xsl:variable name="getValues" select="$rules/Rule[ends-with(@xpath,$thisXPath)][@type='list']/@values"/>
        <xsl:value-of select="substring($getValues,1,string-length($getValues) - 1)"/>
    </xsl:function>
    
