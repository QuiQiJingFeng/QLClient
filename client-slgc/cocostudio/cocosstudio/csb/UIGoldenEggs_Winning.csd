<GameFile>
  <PropertyGroup Name="UIGoldenEggs_Winning" Type="Layer" ID="4748870f-62a9-4f25-9281-855f12ba8a40" Version="3.10.0.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="85" Speed="0.5000">
        <Timeline ActionTag="-1564561818" Property="Scale">
          <ScaleFrame FrameIndex="0" X="1.0000" Y="1.0000">
            <EasingData Type="0" />
          </ScaleFrame>
          <ScaleFrame FrameIndex="85" X="1.0000" Y="1.0000">
            <EasingData Type="0" />
          </ScaleFrame>
        </Timeline>
        <Timeline ActionTag="-1564561818" Property="RotationSkew">
          <ScaleFrame FrameIndex="0" X="0.0000" Y="0.0000">
            <EasingData Type="0" />
          </ScaleFrame>
          <ScaleFrame FrameIndex="85" X="360.0000" Y="360.0000">
            <EasingData Type="0" />
          </ScaleFrame>
        </Timeline>
        <Timeline ActionTag="-1564561818" Property="Alpha">
          <IntFrame FrameIndex="0" Value="255">
            <EasingData Type="0" />
          </IntFrame>
        </Timeline>
        <Timeline ActionTag="-1564561818" Property="CColor">
          <ColorFrame FrameIndex="0" Alpha="255">
            <EasingData Type="0" />
            <Color A="255" R="255" G="246" B="212" />
          </ColorFrame>
          <ColorFrame FrameIndex="20" Alpha="255">
            <EasingData Type="0" />
            <Color A="255" R="255" G="248" B="179" />
          </ColorFrame>
        </Timeline>
        <Timeline ActionTag="1077518247" Property="Scale">
          <ScaleFrame FrameIndex="0" X="0.0100" Y="0.0100">
            <EasingData Type="0" />
          </ScaleFrame>
          <ScaleFrame FrameIndex="10" X="1.2000" Y="1.2000">
            <EasingData Type="0" />
          </ScaleFrame>
          <ScaleFrame FrameIndex="13" X="1.0000" Y="1.0000">
            <EasingData Type="0" />
          </ScaleFrame>
        </Timeline>
      </Animation>
      <ObjectData Name="Layer" Tag="360" ctype="GameLayerObjectData">
        <Size X="1136.0000" Y="640.0000" />
        <Children>
          <AbstractNodeData Name="Panel_GoldenEggs_Winning" ActionTag="1077518247" Tag="51" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="318.0000" RightMargin="318.0000" TopMargin="145.0000" BottomMargin="145.0000" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Enable="True" LeftEage="106" RightEage="106" TopEage="67" BottomEage="67" Scale9OriginX="106" Scale9OriginY="67" Scale9Width="356" Scale9Height="148" ctype="PanelObjectData">
            <Size X="500.0000" Y="350.0000" />
            <Children>
              <AbstractNodeData Name="Image_BG1" ActionTag="1917891258" Tag="751" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="20.0000" RightMargin="20.0000" TopMargin="73.0000" BottomMargin="17.0000" Scale9Enable="True" LeftEage="29" RightEage="29" TopEage="28" BottomEage="28" Scale9OriginX="29" Scale9OriginY="28" Scale9Width="12" Scale9Height="14" ctype="ImageViewObjectData">
                <Size X="460.0000" Y="260.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="250.0000" Y="147.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5000" Y="0.4200" />
                <PreSize X="0.9200" Y="0.7429" />
                <FileData Type="Normal" Path="art/main/Img_bd1_main.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="Button_qd" ActionTag="1917680853" Tag="250" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="145.0000" RightMargin="145.0000" TopMargin="242.0000" BottomMargin="32.0000" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="180" Scale9Height="54" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="210.0000" Y="76.0000" />
                <Children>
                  <AbstractNodeData Name="BitmapFontLabel_2" ActionTag="460030865" Tag="251" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="74.5000" RightMargin="74.5000" TopMargin="20.0000" BottomMargin="20.0000" LabelText="确定" ctype="TextBMFontObjectData">
                    <Size X="61.0000" Y="36.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="105.0000" Y="38.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.5000" Y="0.5000" />
                    <PreSize X="0.2905" Y="0.4737" />
                    <LabelBMFontFile_CNB Type="Normal" Path="art/font/font_Button1.fnt" Plist="" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="250.0000" Y="70.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5000" Y="0.2000" />
                <PreSize X="0.4200" Y="0.2171" />
                <TextColor A="255" R="65" G="65" B="70" />
                <DisabledFileData Type="Normal" Path="art/main/Btn_gray_main.png" Plist="" />
                <PressedFileData Type="Normal" Path="art/main/Btn_red1_main.png" Plist="" />
                <NormalFileData Type="Normal" Path="art/main/Btn_red0_main.png" Plist="" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="Button_X" ActionTag="879641126" VisibleForFrame="False" Tag="728" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="443.0000" RightMargin="-7.0000" TopMargin="-7.5000" BottomMargin="293.5000" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="34" Scale9Height="42" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="64.0000" Y="64.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="475.0000" Y="325.5000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.9500" Y="0.9300" />
                <PreSize X="0.1280" Y="0.1829" />
                <TextColor A="255" R="65" G="65" B="70" />
                <DisabledFileData Type="Normal" Path="art/main/Btn_X_main.png" Plist="" />
                <NormalFileData Type="Normal" Path="art/main/Btn_X_main.png" Plist="" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="Image_top_GoldenEggs_Winning" ActionTag="-1186500183" Tag="729" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="97.0000" RightMargin="97.0000" TopMargin="-3.0000" BottomMargin="277.0000" Scale9Enable="True" LeftEage="320" RightEage="320" TopEage="24" BottomEage="24" Scale9OriginX="-14" Scale9OriginY="24" Scale9Width="334" Scale9Height="28" ctype="ImageViewObjectData">
                <Size X="306.0000" Y="76.0000" />
                <Children>
                  <AbstractNodeData Name="BitmapFontLabel_1" ActionTag="-1714984290" Tag="730" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="92.5000" RightMargin="92.5000" TopMargin="20.0000" BottomMargin="20.0000" LabelText="恭喜中奖" ctype="TextBMFontObjectData">
                    <Size X="121.0000" Y="36.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="153.0000" Y="38.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.5000" Y="0.5000" />
                    <PreSize X="0.3954" Y="0.4737" />
                    <LabelBMFontFile_CNB Type="Normal" Path="art/font/font_title.fnt" Plist="" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="250.0000" Y="315.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5000" Y="0.9000" />
                <PreSize X="0.6120" Y="0.2171" />
                <FileData Type="Normal" Path="art/main/Img_title_main.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="Image_effect" ActionTag="-1564561818" Tag="120" RotationSkewX="110.1177" RotationSkewY="110.1177" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="119.5000" RightMargin="119.5000" TopMargin="27.0000" BottomMargin="62.0000" Scale9Enable="True" LeftEage="5" RightEage="5" TopEage="5" BottomEage="5" Scale9OriginX="5" Scale9OriginY="5" Scale9Width="251" Scale9Height="251" ctype="ImageViewObjectData">
                <Size X="261.0000" Y="261.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="250.0000" Y="192.5000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="248" B="179" />
                <PrePosition X="0.5000" Y="0.5500" />
                <PreSize X="0.5220" Y="0.7457" />
                <FileData Type="Normal" Path="art/effect/gq.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="Image_Item" ActionTag="-781398959" Tag="121" IconVisible="False" PositionPercentYEnabled="True" LeftMargin="195.0000" RightMargin="195.0000" TopMargin="102.5000" BottomMargin="137.5000" LeftEage="5" RightEage="5" TopEage="5" BottomEage="5" Scale9OriginX="5" Scale9OriginY="5" Scale9Width="100" Scale9Height="100" ctype="ImageViewObjectData">
                <Size X="110.0000" Y="110.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="250.0000" Y="192.5000" />
                <Scale ScaleX="1.2000" ScaleY="1.2000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5000" Y="0.5500" />
                <PreSize X="0.2200" Y="0.3143" />
                <FileData Type="Normal" Path="art/mall/goodIcon/icon_fk_mall.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="Particle_1" ActionTag="970355307" Tag="122" IconVisible="True" LeftMargin="252.3186" RightMargin="247.6814" TopMargin="170.0000" BottomMargin="180.0000" ctype="ParticleObjectData">
                <Size X="0.0000" Y="0.0000" />
                <AnchorPoint />
                <Position X="252.3186" Y="180.0000" />
                <Scale ScaleX="1.5000" ScaleY="1.5000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5046" Y="0.5143" />
                <PreSize X="0.0000" Y="0.0000" />
                <FileData Type="Normal" Path="art/effect/dzm.plist" Plist="" />
                <BlendFunc Src="770" Dst="1" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="568.0000" Y="320.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5000" Y="0.5000" />
            <PreSize X="0.4401" Y="0.5469" />
            <FileData Type="Normal" Path="art/main/Img_bd0_main.png" Plist="" />
            <SingleColor A="255" R="150" G="200" B="255" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameFile>