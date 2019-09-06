<GameFile>
  <PropertyGroup Name="UIMallQuickCharge" Type="Layer" ID="dbb68a77-97af-49b2-acf3-ac03fad49075" Version="3.10.0.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="80" Speed="0.5000">
        <Timeline ActionTag="501474897" Property="Scale">
          <ScaleFrame FrameIndex="0" X="1.0000" Y="1.0000">
            <EasingData Type="0" />
          </ScaleFrame>
          <ScaleFrame FrameIndex="20" X="1.3000" Y="1.3000">
            <EasingData Type="0" />
          </ScaleFrame>
          <ScaleFrame FrameIndex="40" X="1.0000" Y="1.0000">
            <EasingData Type="0" />
          </ScaleFrame>
          <ScaleFrame FrameIndex="60" X="1.3000" Y="1.3000">
            <EasingData Type="0" />
          </ScaleFrame>
          <ScaleFrame FrameIndex="80" X="1.0000" Y="1.0000">
            <EasingData Type="0" />
          </ScaleFrame>
        </Timeline>
        <Timeline ActionTag="501474897" Property="RotationSkew">
          <ScaleFrame FrameIndex="0" X="0.0000" Y="0.0000">
            <EasingData Type="0" />
          </ScaleFrame>
          <ScaleFrame FrameIndex="80" X="180.0000" Y="180.0000">
            <EasingData Type="0" />
          </ScaleFrame>
        </Timeline>
      </Animation>
      <ObjectData Name="Layer" Tag="287" ctype="GameLayerObjectData">
        <Size X="1136.0000" Y="640.0000" />
        <Children>
          <AbstractNodeData Name="Layout" ActionTag="-391873791" Tag="295" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="228.0000" RightMargin="228.0000" TopMargin="70.0000" BottomMargin="70.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Enable="True" LeftEage="140" RightEage="110" TopEage="80" BottomEage="70" Scale9OriginX="140" Scale9OriginY="80" Scale9Width="318" Scale9Height="132" ctype="PanelObjectData">
            <Size X="680.0000" Y="500.0000" />
            <Children>
              <AbstractNodeData Name="forNM" ActionTag="-1589422172" Tag="3722" IconVisible="False" RightMargin="20.0000" BottomMargin="438.0000" Scale9Enable="True" LeftEage="60" RightEage="60" TopEage="20" BottomEage="20" Scale9OriginX="60" Scale9OriginY="20" Scale9Width="5" Scale9Height="22" ctype="ImageViewObjectData">
                <Size X="660.0000" Y="62.0000" />
                <AnchorPoint ScaleY="1.0000" />
                <Position Y="500.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition Y="1.0000" />
                <PreSize X="0.9706" Y="0.1240" />
                <FileData Type="Normal" Path="art/img/forneimeng.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="BG" ActionTag="-1665593135" Tag="2148" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="20.0000" RightMargin="20.0000" TopMargin="73.0000" BottomMargin="17.0000" Scale9Enable="True" LeftEage="29" RightEage="29" TopEage="28" BottomEage="28" Scale9OriginX="29" Scale9OriginY="28" Scale9Width="12" Scale9Height="14" ctype="ImageViewObjectData">
                <Size X="640.0000" Y="410.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="340.0000" Y="222.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5000" Y="0.4440" />
                <PreSize X="0.9412" Y="0.8200" />
                <FileData Type="Normal" Path="art/main/Img_bd1_main.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="ImageView_Title" ActionTag="-1861720088" Tag="296" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" PercentWidthEnable="True" PercentWidthEnabled="True" LeftMargin="163.2000" RightMargin="163.2000" TopMargin="-3.0000" BottomMargin="427.0000" Scale9Enable="True" LeftEage="320" RightEage="320" TopEage="24" BottomEage="24" Scale9OriginX="-14" Scale9OriginY="24" Scale9Width="334" Scale9Height="28" ctype="ImageViewObjectData">
                <Size X="353.6000" Y="76.0000" />
                <Children>
                  <AbstractNodeData Name="BMFont_Title" ActionTag="-488155267" Tag="918" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="84.5320" RightMargin="88.0680" TopMargin="21.9228" BottomMargin="18.0772" LabelText="金豆货币不足" ctype="TextBMFontObjectData">
                    <Size X="181.0000" Y="36.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="175.0320" Y="36.0772" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.4950" Y="0.4747" />
                    <PreSize X="0.5119" Y="0.4737" />
                    <LabelBMFontFile_CNB Type="Normal" Path="art/font/font_title.fnt" Plist="" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="340.0000" Y="465.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5000" Y="0.9300" />
                <PreSize X="0.5200" Y="0.1520" />
                <FileData Type="Normal" Path="art/main/Img_title_main.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="BG_Bottom" ActionTag="2023167763" Tag="298" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="24.0000" RightMargin="24.0000" TopMargin="382.0000" BottomMargin="22.0000" Scale9Enable="True" LeftEage="10" RightEage="10" TopEage="10" BottomEage="10" Scale9OriginX="10" Scale9OriginY="10" Scale9Width="44" Scale9Height="70" ctype="ImageViewObjectData">
                <Size X="632.0000" Y="96.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="340.0000" Y="70.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5000" Y="0.1400" />
                <PreSize X="0.9294" Y="0.1920" />
                <FileData Type="Normal" Path="art/main/Img_bd3_main.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="Button_Abandon" ActionTag="860376244" Tag="299" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="405.0000" RightMargin="65.0000" TopMargin="392.0000" BottomMargin="32.0000" TouchEnable="True" FontSize="24" Scale9Enable="True" LeftEage="60" RightEage="60" TopEage="11" BottomEage="11" Scale9OriginX="60" Scale9OriginY="11" Scale9Width="90" Scale9Height="54" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="210.0000" Y="76.0000" />
                <Children>
                  <AbstractNodeData Name="BMFont" ActionTag="-1310578553" Tag="2852" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="74.5000" RightMargin="74.5000" TopMargin="20.0000" BottomMargin="20.0000" LabelText="放弃" ctype="TextBMFontObjectData">
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
                <Position X="510.0000" Y="70.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.7500" Y="0.1400" />
                <PreSize X="0.3088" Y="0.1520" />
                <TextColor A="255" R="65" G="65" B="70" />
                <DisabledFileData Type="Normal" Path="art/main/Btn_gray_main.png" Plist="" />
                <PressedFileData Type="Normal" Path="art/main/Btn_red1_main.png" Plist="" />
                <NormalFileData Type="Normal" Path="art/main/Btn_red0_main.png" Plist="" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="Button_Buy" ActionTag="1984320377" Tag="300" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="65.0000" RightMargin="405.0000" TopMargin="392.0000" BottomMargin="32.0000" TouchEnable="True" FontSize="24" Scale9Enable="True" LeftEage="60" RightEage="60" TopEage="11" BottomEage="11" Scale9OriginX="60" Scale9OriginY="11" Scale9Width="90" Scale9Height="54" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="210.0000" Y="76.0000" />
                <Children>
                  <AbstractNodeData Name="BMFont_Price" ActionTag="867917571" Tag="2853" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="97.0830" RightMargin="30.9170" TopMargin="20.0000" BottomMargin="20.0000" LabelText="325元" ctype="TextBMFontObjectData">
                    <Size X="82.0000" Y="36.0000" />
                    <AnchorPoint ScaleY="0.5000" />
                    <Position X="97.0830" Y="38.0000" />
                    <Scale ScaleX="1.2000" ScaleY="1.2000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.4623" Y="0.5000" />
                    <PreSize X="0.3905" Y="0.4737" />
                    <LabelBMFontFile_CNB Type="Normal" Path="art/font/font_Button1.fnt" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="Icon" ActionTag="590542682" Tag="63" IconVisible="False" LeftMargin="-41.2796" RightMargin="71.2796" TopMargin="-21.4495" BottomMargin="-22.5505" LeftEage="13" RightEage="13" TopEage="13" BottomEage="13" Scale9OriginX="13" Scale9OriginY="13" Scale9Width="154" Scale9Height="94" ctype="ImageViewObjectData">
                    <Size X="180.0000" Y="120.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="48.7204" Y="37.4495" />
                    <Scale ScaleX="0.7000" ScaleY="0.7000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.2320" Y="0.4928" />
                    <PreSize X="0.8571" Y="1.5789" />
                    <FileData Type="Normal" Path="art/mall/goodIcon/icon_gold3_mall.png" Plist="" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="170.0000" Y="70.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.2500" Y="0.1400" />
                <PreSize X="0.3088" Y="0.1520" />
                <TextColor A="255" R="65" G="65" B="70" />
                <DisabledFileData Type="Normal" Path="art/main/Btn_gray_main.png" Plist="" />
                <PressedFileData Type="Normal" Path="art/main/Btn_green1_main.png" Plist="" />
                <NormalFileData Type="Normal" Path="art/main/Btn_green0_main.png" Plist="" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="Text_Slogan" ActionTag="384998091" Tag="306" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="65.0000" RightMargin="65.0000" TopMargin="96.0000" BottomMargin="376.0000" IsCustomSize="True" FontSize="24" LabelText="推荐您购买12数量，只要（325元 /35金豆)" HorizontalAlignmentType="HT_Center" VerticalAlignmentType="VT_Center" ShadowOffsetX="1.0000" ShadowOffsetY="-1.0000" ctype="TextObjectData">
                <Size X="550.0000" Y="28.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="340.0000" Y="390.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="164" G="137" B="69" />
                <PrePosition X="0.5000" Y="0.7800" />
                <PreSize X="0.8088" Y="0.0560" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="88" G="34" B="0" />
              </AbstractNodeData>
              <AbstractNodeData Name="Button_Close" ActionTag="258836440" VisibleForFrame="False" Tag="884" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="620.8000" RightMargin="-4.8000" TopMargin="-7.0000" BottomMargin="443.0000" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="34" Scale9Height="42" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="64.0000" Y="64.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="652.8000" Y="475.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.9600" Y="0.9500" />
                <PreSize X="0.0941" Y="0.1280" />
                <TextColor A="255" R="65" G="65" B="70" />
                <DisabledFileData Type="Normal" Path="art/main/Btn_X_main.png" Plist="" />
                <NormalFileData Type="Normal" Path="art/main/Btn_X_main.png" Plist="" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="BG" ActionTag="501474897" Alpha="150" Tag="37" IconVisible="False" LeftMargin="199.5000" RightMargin="219.5000" TopMargin="119.5000" BottomMargin="119.5000" LeftEage="86" RightEage="86" TopEage="86" BottomEage="86" Scale9OriginX="86" Scale9OriginY="86" Scale9Width="89" Scale9Height="89" ctype="ImageViewObjectData">
                <Size X="261.0000" Y="261.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="330.0000" Y="250.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="188" B="63" />
                <PrePosition X="0.4853" Y="0.5000" />
                <PreSize X="0.3838" Y="0.5220" />
                <FileData Type="Normal" Path="art/effect/gq.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="Image_Icon_Center" ActionTag="126732116" Tag="36" IconVisible="False" LeftMargin="235.8677" RightMargin="264.1323" TopMargin="181.4241" BottomMargin="198.5759" LeftEage="84" RightEage="84" TopEage="39" BottomEage="39" Scale9OriginX="84" Scale9OriginY="39" Scale9Width="12" Scale9Height="42" ctype="ImageViewObjectData">
                <Size X="180.0000" Y="120.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="325.8677" Y="258.5759" />
                <Scale ScaleX="1.3000" ScaleY="1.3000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.4792" Y="0.5172" />
                <PreSize X="0.2647" Y="0.2400" />
                <FileData Type="Normal" Path="art/mall/goodIcon/icon_bean7_mall.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="BMFont_Name" ActionTag="955725660" Tag="38" IconVisible="False" PositionPercentXEnabled="True" LeftMargin="283.0000" RightMargin="283.0000" TopMargin="343.0000" BottomMargin="121.0000" LabelText="金豆X50" ctype="TextBMFontObjectData">
                <Size X="114.0000" Y="36.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="340.0000" Y="139.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="192" G="159" B="82" />
                <PrePosition X="0.5000" Y="0.2780" />
                <PreSize X="0.1676" Y="0.0720" />
                <LabelBMFontFile_CNB Type="Normal" Path="art/font/font_title2.fnt" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="Particle_1" ActionTag="-1189551433" Tag="39" IconVisible="True" LeftMargin="322.0001" RightMargin="357.9999" TopMargin="253.9999" BottomMargin="246.0001" ctype="ParticleObjectData">
                <Size X="0.0000" Y="0.0000" />
                <AnchorPoint />
                <Position X="322.0001" Y="246.0001" />
                <Scale ScaleX="2.5000" ScaleY="2.5000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.4735" Y="0.4920" />
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
            <PreSize X="0.5986" Y="0.7813" />
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