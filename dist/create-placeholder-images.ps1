# 批量创建占位图片的PowerShell脚本

# 课程图片
$courseImages = @{
    "hand-drawing.jpg" = @("手绘课程", "建筑手绘技法", "#E91E63")
    "architecture-photography.jpg" = @("建筑摄影", "摄影技巧课程", "#9C27B0")
    "building-materials.jpg" = @("建筑材料", "材料学基础", "#795548")
    "architecture-history.jpg" = @("建筑史", "建筑历史课程", "#607D8B")
    "drawing-standards.jpg" = @("制图标准", "工程制图规范", "#FF5722")
    "autocad-advanced.jpg" = @("AutoCAD 高级", "高级建模技术", "#4CAF50")
    "revit-collaboration.jpg" = @("Revit 协作", "BIM协作流程", "#00BCD4")
    "design-analysis.jpg" = @("设计分析", "建筑分析方法", "#FFC107")
    "revit-bim.jpg" = @("Revit BIM", "BIM建模课程", "#3F51B5")
    "residential-design.jpg" = @("住宅设计", "居住建筑设计", "#8BC34A")
}

# 购物车课程图片
$cartCourses = @{
    "autocad-2024.jpg" = @("AutoCAD 2024", "最新版本教程", "#4CAF50")
    "sketchup-design.jpg" = @("SketchUp 设计", "3D设计实战", "#FF9800")
    "3dsmax-render.jpg" = @("3ds Max 渲染", "高级渲染技术", "#F44336")
    "lumion-animation.jpg" = @("Lumion 动画", "建筑动画制作", "#2196F3")
    "ps-architecture.jpg" = @("PS 建筑", "建筑后期处理", "#9C27B0")
}

# 创建课程图片
foreach ($file in $courseImages.Keys) {
    $info = $courseImages[$file]
    $title = $info[0]
    $subtitle = $info[1]
    $color = $info[2]
    
    $svg = @"
<svg width="400" height="300" xmlns="http://www.w3.org/2000/svg">
  <rect width="100%" height="100%" fill="#f8f8f8"/>
  <rect x="20" y="20" width="360" height="260" fill="#eeeeee" stroke="#ccc" stroke-width="2"/>
  <text x="200" y="120" text-anchor="middle" font-family="Arial, sans-serif" font-size="24" fill="#666">$title</text>
  <text x="200" y="160" text-anchor="middle" font-family="Arial, sans-serif" font-size="16" fill="#888">$subtitle</text>
  <circle cx="200" cy="200" r="30" fill="$color" opacity="0.7"/>
  <text x="200" y="210" text-anchor="middle" font-family="Arial, sans-serif" font-size="12" fill="white">课程</text>
</svg>
"@
    
    $svg | Out-File -FilePath "course-images\$file" -Encoding UTF8
}

# 创建购物车课程图片
foreach ($file in $cartCourses.Keys) {
    $info = $cartCourses[$file]
    $title = $info[0]
    $subtitle = $info[1]
    $color = $info[2]
    
    $svg = @"
<svg width="400" height="300" xmlns="http://www.w3.org/2000/svg">
  <rect width="100%" height="100%" fill="#f8f8f8"/>
  <rect x="20" y="20" width="360" height="260" fill="#eeeeee" stroke="#ccc" stroke-width="2"/>
  <text x="200" y="120" text-anchor="middle" font-family="Arial, sans-serif" font-size="24" fill="#666">$title</text>
  <text x="200" y="160" text-anchor="middle" font-family="Arial, sans-serif" font-size="16" fill="#888">$subtitle</text>
  <circle cx="200" cy="200" r="30" fill="$color" opacity="0.7"/>
  <text x="200" y="210" text-anchor="middle" font-family="Arial, sans-serif" font-size="12" fill="white">课程</text>
</svg>
"@
    
    $svg | Out-File -FilePath "courses\$file" -Encoding UTF8
}

# 创建更多用户头像
$colors = @("#4CAF50", "#2196F3", "#FF9800", "#E91E63", "#9C27B0", "#00BCD4", "#FFC107")
for ($i = 2; $i -le 7; $i++) {
    $color = $colors[$i % $colors.Length]
    $svg = @"
<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="50" r="50" fill="$color"/>
  <circle cx="50" cy="35" r="15" fill="white"/>
  <path d="M 25 70 Q 50 55 75 70 L 75 100 L 25 100 Z" fill="white"/>
  <text x="50" y="90" text-anchor="middle" font-family="Arial, sans-serif" font-size="8" fill="$color">讲师</text>
</svg>
"@
    $svg | Out-File -FilePath "avatars\instructor-$i.jpg" -Encoding UTF8
}

# 创建更多用户头像
for ($i = 3; $i -le 5; $i++) {
    $color = $colors[$i % $colors.Length]
    $svg = @"
<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="50" r="50" fill="$color"/>
  <circle cx="50" cy="35" r="15" fill="white"/>
  <path d="M 25 70 Q 50 55 75 70 L 75 100 L 25 100 Z" fill="white"/>
  <text x="50" y="90" text-anchor="middle" font-family="Arial, sans-serif" font-size="8" fill="$color">用户</text>
</svg>
"@
    $svg | Out-File -FilePath "avatars\user-$i.jpg" -Encoding UTF8
}

# 创建当前用户头像
$svg = @"
<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="50" r="50" fill="#FF5722"/>
  <circle cx="50" cy="35" r="15" fill="white"/>
  <path d="M 25 70 Q 50 55 75 70 L 75 100 L 25 100 Z" fill="white"/>
  <text x="50" y="90" text-anchor="middle" font-family="Arial, sans-serif" font-size="8" fill="#FF5722">我</text>
</svg>
"@
$svg | Out-File -FilePath "avatars\current-user.jpg" -Encoding UTF8

# 创建帖子图片
for ($i = 1; $i -le 4; $i++) {
    for ($j = 1; $j -le 3; $j++) {
        $color = $colors[($i + $j) % $colors.Length]
        $svg = @"
<svg width="300" height="200" xmlns="http://www.w3.org/2000/svg">
  <rect width="100%" height="100%" fill="#f5f5f5"/>
  <rect x="10" y="10" width="280" height="180" fill="$color" opacity="0.1" stroke="$color" stroke-width="2"/>
  <text x="150" y="100" text-anchor="middle" font-family="Arial, sans-serif" font-size="18" fill="#666">帖子图片 $i-$j</text>
  <circle cx="150" cy="130" r="20" fill="$color" opacity="0.7"/>
</svg>
"@
        $svg | Out-File -FilePath "posts\post-$i-$j.jpg" -Encoding UTF8
    }
}

Write-Host "所有占位图片创建完成！"