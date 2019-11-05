<GameFile>
  <PropertyGroup Name="Effect_Money0" Type="Layer" ID="ac9bed88-894e-4e91-b9c5-cc231d5c87a5" Version="3.10.0.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="30" Speed="0.5000">
        <Timeline ActionTag="1589318215" Property="Scale">
          <ScaleFrame FrameIndex="0" X="0.5000" Y="0.5000">
            <EasingData Type="0" />
          </ScaleFrame>
          <ScaleFrame FrameIndex="10" X="1.2000" Y="1.2000">
            <EasingData Type="0" />
          </ScaleFrame>
          <ScaleFrame FrameIndex="12" X="1.0000" Y="1.0000">
            <EasingData Type="0" />
          </ScaleFrame>
        </Timeline>
        <Timeline ActionTag="1589318215" Property="Alpha">
          <IntFrame FrameIndex="0" Value="0">
            <EasingData Type="0" />
          </IntFrame>
          <IntFrame FrameIndex="10" Value="255">
            <EasingData Type="0" />
          </IntFrame>
          <IntFrame FrameIndex="30" Value="255">
            <EasingData Type="0" />
          </IntFrame>
        </Timeline>
      </Animation>
      <ObjectData Name="Layer" Tag="153" ctype="GameLayerObjectData">
        <Size X="1136.0000" Y="640.0000" />
        <Children>
          <AbstractNodeData Name="Mask" ActionTag="581606414" Alpha="178" UserData="background" Tag="390" IconVisible="False" PercentWidthEnable="True" PercentHeightEnable="True" PercentWidthEnabled="True" PercentHeightEnabled="True" TouchEnable="True" Scale9Enable="True" LeftEage="2" RightEage="2" TopEage="2" BottomEage="2" Scale9OriginX="2" Scale9OriginY="2" Scale9Width="4" Scale9Height="4" ctype="ImageViewObjectData">
            <Size X="1136.0000" Y="640.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="568.0000" Y="320.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5000" Y="0.5000" />
            <PreSize X="1.0000" Y="1.0000" />
            <FileData Type="Normal" Path="art/gaming/blackMask.png" Plist="" />
          </AbstractNodeData>
          <AbstractNodeData Name="Panel_money0" ActionTag="-1656400229" Tag="154" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="318.0000" RightMargin="318.0000" TopMargin="6.0000" BottomMargin="134.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
            <Size X="500.0000" Y="500.0000" />
            <Children>
              <AbstractNodeData Name="Image_5_money" ActionTag="1589318215" Tag="159" IconVisible="False" LeftMargin="59.0000" RightMargin="59.0000" TopMargin="192.5000" BottomMargin="52.5000" LeftEage="42" RightEage="42" TopEage="10" BottomEage="10" Scale9OriginX="42" Scale9OriginY="10" Scale9Width="298" Scale9Height="235" ctype="ImageViewObjectData">
                <Size X="382.0000" Y="255.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="250.0000" Y="180.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5000" Y="0.3600" />
                <PreSize X="0.7640" Y="0.5100" />
                <FileData Type="Normal" Path="art/gold/img_gold.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="Particle_1" ActionTag="1088035782" Tag="1818" IconVisible="True" LeftMargin="257.3136" RightMargin="242.6864" TopMargin="244.7753" BottomMargin="255.2247" ctype="ParticleObjectData">
                <Size X="0.0000" Y="0.0000" />
                <AnchorPoint />
                <Position X="257.3136" Y="255.2247" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5146" Y="0.5104" />
                <PreSize X="0.0000" Y="0.0000" />
                <FileData Type="Normal" Path="art/effect/dzm.plist" Plist="" />
                <BlendFunc Src="770" Dst="1" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="568.0000" Y="384.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5000" Y="0.6000" />
            <PreSize X="0.4401" Y="0.7813" />
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