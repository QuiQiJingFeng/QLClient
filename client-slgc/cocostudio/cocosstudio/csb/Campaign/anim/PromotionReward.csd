<GameFile>
  <PropertyGroup Name="PromotionReward" Type="Node" ID="a5bc77ab-a383-4fa7-81bf-ba4f33a8eb6b" Version="3.10.0.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="80" Speed="0.5000" ActivedAnimationName="animation0">
        <Timeline ActionTag="1101530932" Property="Scale">
          <ScaleFrame FrameIndex="5" X="0.0100" Y="1.0000">
            <EasingData Type="0" />
          </ScaleFrame>
          <ScaleFrame FrameIndex="10" X="1.2000" Y="1.2000">
            <EasingData Type="0" />
          </ScaleFrame>
          <ScaleFrame FrameIndex="80" X="1.2000" Y="1.2000">
            <EasingData Type="0" />
          </ScaleFrame>
        </Timeline>
        <Timeline ActionTag="1101530932" Property="Alpha">
          <IntFrame FrameIndex="5" Value="0">
            <EasingData Type="0" />
          </IntFrame>
          <IntFrame FrameIndex="10" Value="255">
            <EasingData Type="0" />
          </IntFrame>
          <IntFrame FrameIndex="80" Value="255">
            <EasingData Type="0" />
          </IntFrame>
        </Timeline>
        <Timeline ActionTag="1101530932" Property="Position">
          <PointFrame FrameIndex="80" X="0.0000" Y="0.0000">
            <EasingData Type="0" />
          </PointFrame>
        </Timeline>
        <Timeline ActionTag="1101530932" Property="RotationSkew">
          <ScaleFrame FrameIndex="80" X="0.0000" Y="0.0000">
            <EasingData Type="0" />
          </ScaleFrame>
        </Timeline>
        <Timeline ActionTag="-1179667828" Property="Scale">
          <ScaleFrame FrameIndex="80" X="1.0000" Y="1.0000">
            <EasingData Type="0" />
          </ScaleFrame>
        </Timeline>
        <Timeline ActionTag="-1179667828" Property="Alpha">
          <IntFrame FrameIndex="80" Value="255">
            <EasingData Type="0" />
          </IntFrame>
        </Timeline>
        <Timeline ActionTag="-1179667828" Property="Position">
          <PointFrame FrameIndex="80" X="0.0000" Y="50.0000">
            <EasingData Type="0" />
          </PointFrame>
        </Timeline>
        <Timeline ActionTag="-1179667828" Property="RotationSkew">
          <ScaleFrame FrameIndex="80" X="0.0000" Y="0.0000">
            <EasingData Type="0" />
          </ScaleFrame>
        </Timeline>
      </Animation>
      <AnimationList>
        <AnimationInfo Name="animation0" StartIndex="0" EndIndex="80">
          <RenderColor A="255" R="139" G="0" B="139" />
        </AnimationInfo>
      </AnimationList>
      <ObjectData Name="Node" Tag="372" ctype="GameNodeObjectData">
        <Size X="0.0000" Y="0.0000" />
        <Children>
          <AbstractNodeData Name="Image_2" ActionTag="1101530932" Alpha="0" Tag="368" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="-568.0000" RightMargin="-568.0000" TopMargin="-100.0000" BottomMargin="-100.0000" Scale9Enable="True" TopEage="11" BottomEage="11" Scale9OriginY="11" Scale9Width="256" Scale9Height="42" ctype="ImageViewObjectData">
            <Size X="1136.0000" Y="200.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position />
            <Scale ScaleX="0.0100" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition />
            <PreSize X="0.0000" Y="0.0000" />
            <FileData Type="Normal" Path="art/campaign/Arena/dwwww.png" Plist="" />
          </AbstractNodeData>
          <AbstractNodeData Name="BitmapFontLabel_1_0" ActionTag="268026922" Tag="999" IconVisible="False" LeftMargin="-330.5000" RightMargin="-332.5000" TopMargin="-6.0000" BottomMargin="-84.0000" LabelText="第三轮 前99名晋级" ctype="TextBMFontObjectData">
            <Size X="663.0000" Y="90.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="1.0000" Y="-39.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition />
            <PreSize X="0.0000" Y="0.0000" />
            <LabelBMFontFile_CNB Type="Normal" Path="art/font/font_Arena.fnt" Plist="" />
          </AbstractNodeData>
          <AbstractNodeData Name="BitmapFontLabel_1_0_0" ActionTag="-1179667828" Tag="541" IconVisible="False" PositionPercentXEnabled="True" LeftMargin="-275.5000" RightMargin="-275.5000" TopMargin="-95.0000" BottomMargin="5.0000" LabelText="恭喜进入奖励圈！" ctype="TextBMFontObjectData">
            <Size X="551.0000" Y="90.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position Y="50.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition />
            <PreSize X="0.0000" Y="0.0000" />
            <LabelBMFontFile_CNB Type="Normal" Path="art/font/font_Arena.fnt" Plist="" />
          </AbstractNodeData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameFile>