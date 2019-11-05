<GameFile>
  <PropertyGroup Name="Effect_frame" Type="Layer" ID="62288029-3f46-4186-b705-d821d8f891d7" Version="3.10.0.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="200" Speed="0.5000">
        <Timeline ActionTag="-281288588" Property="Scale">
          <ScaleFrame FrameIndex="0" X="0.8000" Y="0.8000">
            <EasingData Type="0" />
          </ScaleFrame>
          <ScaleFrame FrameIndex="50" X="0.9000" Y="0.9000">
            <EasingData Type="0" />
          </ScaleFrame>
          <ScaleFrame FrameIndex="100" X="0.8000" Y="0.8000">
            <EasingData Type="0" />
          </ScaleFrame>
          <ScaleFrame FrameIndex="150" X="0.9000" Y="0.9000">
            <EasingData Type="0" />
          </ScaleFrame>
          <ScaleFrame FrameIndex="200" X="0.8000" Y="0.8000">
            <EasingData Type="0" />
          </ScaleFrame>
        </Timeline>
        <Timeline ActionTag="-281288588" Property="Alpha">
          <IntFrame FrameIndex="0" Value="255">
            <EasingData Type="0" />
          </IntFrame>
          <IntFrame FrameIndex="50" Value="191">
            <EasingData Type="0" />
          </IntFrame>
          <IntFrame FrameIndex="100" Value="255">
            <EasingData Type="0" />
          </IntFrame>
          <IntFrame FrameIndex="150" Value="191">
            <EasingData Type="0" />
          </IntFrame>
          <IntFrame FrameIndex="200" Value="255">
            <EasingData Type="0" />
          </IntFrame>
        </Timeline>
        <Timeline ActionTag="-281288588" Property="RotationSkew">
          <ScaleFrame FrameIndex="0" X="0.0000" Y="0.0000">
            <EasingData Type="0" />
          </ScaleFrame>
          <ScaleFrame FrameIndex="200" X="360.0000" Y="360.0000">
            <EasingData Type="0" />
          </ScaleFrame>
        </Timeline>
        <Timeline ActionTag="1677119520" Property="Position">
          <PointFrame FrameIndex="0" X="568.0000" Y="321.0000">
            <EasingData Type="0" />
          </PointFrame>
        </Timeline>
        <Timeline ActionTag="-97281496" Property="FileData">
          <TextureFrame FrameIndex="0" Tween="False">
            <TextureFile Type="Normal" Path="art/gaming/Icon_frame.png" Plist="" />
          </TextureFrame>
        </Timeline>
        <Timeline ActionTag="-97281496" Property="BlendFunc">
          <BlendFuncFrame FrameIndex="0" Tween="False" Src="1" Dst="771" />
        </Timeline>
      </Animation>
      <ObjectData Name="Effect_frame" Tag="422" ctype="GameLayerObjectData">
        <Size X="1136.0000" Y="640.0000" />
        <Children>
          <AbstractNodeData Name="Panel_frame" ActionTag="1905184719" Tag="423" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" PercentWidthEnable="True" PercentHeightEnable="True" PercentWidthEnabled="True" PercentHeightEnabled="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" LeftEage="122" RightEage="122" TopEage="36" BottomEage="36" Scale9OriginX="-122" Scale9OriginY="-36" Scale9Width="244" Scale9Height="72" ctype="PanelObjectData">
            <Size X="1136.0000" Y="640.0000" />
            <Children>
              <AbstractNodeData Name="Image_0_frame" ActionTag="-281288588" Tag="92" IconVisible="False" LeftMargin="513.0000" RightMargin="513.0000" TopMargin="265.0000" BottomMargin="265.0000" LeftEage="26" RightEage="26" TopEage="24" BottomEage="24" Scale9OriginX="26" Scale9OriginY="24" Scale9Width="58" Scale9Height="62" ctype="ImageViewObjectData">
                <Size X="110.0000" Y="110.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="568.0000" Y="320.0000" />
                <Scale ScaleX="0.8000" ScaleY="0.8000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5000" Y="0.5000" />
                <PreSize X="0.0968" Y="0.1719" />
                <FileData Type="Normal" Path="art/effect/Effect_7.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="Particle_1" ActionTag="1677119520" Tag="160" IconVisible="True" LeftMargin="568.0000" RightMargin="568.0000" TopMargin="319.0000" BottomMargin="321.0000" ctype="ParticleObjectData">
                <Size X="0.0000" Y="0.0000" />
                <AnchorPoint />
                <Position X="568.0000" Y="321.0000" />
                <Scale ScaleX="1.2000" ScaleY="1.2000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5000" Y="0.5016" />
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
            <PreSize X="1.0000" Y="1.0000" />
            <SingleColor A="255" R="150" G="200" B="255" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
          <AbstractNodeData Name="Icon_frame_player1_Scene" ActionTag="-97281496" Tag="159" IconVisible="False" LeftMargin="536.0000" RightMargin="536.0000" TopMargin="287.9541" BottomMargin="288.0459" ctype="SpriteObjectData">
            <Size X="64.0000" Y="64.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="568.0000" Y="320.0459" />
            <Scale ScaleX="1.0500" ScaleY="1.0500" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5000" Y="0.5001" />
            <PreSize X="0.0563" Y="0.1000" />
            <FileData Type="Normal" Path="art/gaming/Icon_frame.png" Plist="" />
            <BlendFunc Src="1" Dst="771" />
          </AbstractNodeData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameFile>