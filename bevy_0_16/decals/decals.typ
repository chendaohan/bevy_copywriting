#set page(fill: rgb(35, 35, 38, 255), height: auto)
#set text(fill: color.hsv(0deg, 0%, 90%, 100%), font: "Microsoft YaHei")
#set raw(theme: "theme/Material-Theme.tmTheme")

大家好，我是平凡的小梦。我们一起来看一下 Bevy 0.16 中的新功能“贴花（Decals）”。

== 1. 贴花是什么？
贴花是一种可以动态叠加在现有网格上的纹理，并能贴合其几何形状。用于增强环境细节而不需要修改低层模型或纹理。

== 2. 贴花的优点和应用
- 你可以根据玩家的动作，动态的添加贴花，例如：游戏中的弹孔、油漆
#figure(
    image("assets/弹孔.png"),
    caption: [
        弹孔，来源：https://www.bilibili.com/video/BV1sg4y1K7bY/?spm_id_from=333.337.search-card.all.click&vd_source=95996a43fe74c1ac7370ed69080f0833
    ]
)

#figure(
    image("assets/油漆.png"),
    caption: [
        油漆，来源：https://www.bilibili.com/video/BV1xh4y1T75n/?spm_id_from=333.1387.homepage.video_card.click&vd_source=95996a43fe74c1ac7370ed69080f0833
    ]
)

- 你无需为每种组合都创建一张新纹理，这使得在关卡中添加一些细节更加高效灵活，例如：墙上的涂鸦，地面的水坑、裂纹
#figure(
    image("assets/涂鸦.png"),
    caption: [
        涂鸦，来源：https://www.bilibili.com/video/BV1ebzFYhEy2?spm_id_from=333.788.videopod.episodes&vd_source=95996a43fe74c1ac7370ed69080f0833&p=3
    ]
)

#figure(
    image("assets/水坑和裂纹.png"),
    caption: [
        水坑和裂纹，来源：https://www.bilibili.com/video/BV1im421g7Ef?spm_id_from=333.788.videopod.episodes&vd_source=95996a43fe74c1ac7370ed69080f0833&p=2
    ]
)

== 3. Bevy 0.16 中的贴花
和许多渲染功能一样，贴花有多种实现方式，每种实现都有其优势。在 Bevy 0.16 中有两种互补的实现：前向贴花（Forward Decals）和集群贴花（Clustered Decals）。未来可能还会有一个延迟贴花（Deferred Decals）。

- 前向贴花（Forward Decals）
Bevy 前向贴花（更准确地说，是接触投影贴花）的实现灵感来自“流放之路 2（Path of Exile 2）”的渲染技术演讲，并从生态 crate `bevy_contact_projective_decals` 中引入。由于这种技术的特性，从非常倾斜的角度观察贴花会出现失真。可以通过使用比实际效果更大的贴图来缓解这种问题，从而给贴花留出更多的拉伸空间。

这种贴花本质上是一个 1m x 1m 的平面网格，通过 Transform 中的缩放可以调整大小。

要创建前向贴花，可以生成一个 ForwardDecal 实体，它使用 ForwardDecalMaterial，并通过 ForwardDecalMaterialExt 材质扩展进行设置。

#figure(
    image("assets/forward_decals.png"),
    caption: [前向贴花，图片中的蓝色边框和方向轴是我为了辅助大家理解而添加的，不是前向贴花的一部分]
)

- 集群贴花（Clustered Decals）
集群贴花（或称贴花投影器）通过从 1m x 1m x 1m 的立方体向 -Z 方向投影图像到表面上来工作。它们是可以被“聚类”的对象，类似于点光源和光探针。这意味着贴花只会作用于在投影器范围内的物体。

可以通过 Transform 中的缩放调整贴花大小和投影距离。

注意，集群贴花的 API 文档中向 +Z 方向投射的说法是错误的，实测是 -Z 方向，在 Bevy 中 -Z 是正面，+Z 是背面。我已经为这个文档错误提交了 Issue （https://github.com/bevyengine/bevy/issues/19612）。

要创建一个集群贴花，可以生成一个 ClusteredDecal 实体。

#figure(
    image("assets/clustered_decals.png"),
    caption: [集群贴花，图片中的白色边框和方向轴是我为了辅助大家理解而添加的，不是集群贴花的一部分]
)

总的来说，前向贴花具有更广泛的硬件和驱动支持，而集群贴花则具有更高的渲染质量，并且不需要额外创建包围几何体，从而提升了性能。

目前，集群贴花依赖于无绑定纹理（bindless textures），因此不支持 WebGL2、WebGPU、iOS 和 macOS 平台，其中 ios 和 macOS 未来大概率支持。而前向贴花在这些平台上是可用的。

需要注意的是，目前只要在贴花的影响范围之内，就会受到影响，无法使处于影响范围之内的物体不受影响。也就是说，如果你用现在的 Bevy 贴花制作弹孔、涂鸦、水坑，玩家进入它们的影响范围，这些贴花也会投影到玩家身上，无法将玩家从影响中排除。

当然也不是绝对的，通过编写片元着色器，可以实现此功能，但很麻烦。我已经提了一个请求此类功能的 Issue （https://github.com/bevyengine/bevy/issues/19607）。