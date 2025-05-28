B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=13.1
@EndOfDesignText@
#Region  Activity Attributes 
    #FullScreen: true
    #IncludeTitle: false
#End Region

Sub Process_Globals
	Private MovingPlatforms As List
	Private startTimer,NextStageTimer As Timer
	Private countdown As Int = 5
	Private PlayerHealth As Int = 3
	Private gameStarted As Boolean = False
    
	Private GamePaused As Boolean
	Private GameOver As Boolean
	Private CoinAnimationStep As Int = 0
	Private CoinAnimationDirection As Int = 1
	Private Const COIN_ANIMATION_RANGE As Int = 10
	Private Const cPI1 As Double = 3.141592653589793
	Private Const MAX_BULLETS As Int = 5
	Private Const BULLET_SPEED As Int = 30
	Private SpringCloseBitmap, SpringOpenBitmap As Bitmap
	Private mStartX, mStartY, mEndX, mEndY As Int

	Private mColor As Int
	Private mWidth As Int
	Private Const MAX_VIEWS As Int = 200
	Private MaxParticles As Int = 100
	Private PowerupActive As Boolean
	Private PowerupType As String
	Private PowerupTimer As Timer
	Private PowerupDuration As Int = 10000
	Private OriginalGravity As Float = 0.5
	Private HelicopterMode As Boolean = False
	Private Const JUMP_FORCE As Float = -25
	Private Const SUPER_JUMP_FORCE As Float = -50
	Private Gravity1 As Float = 0.4
	Private Const MAX_HORIZONTAL_SPEED As Float = 12
	Private Const MAX_FALL_SPEED As Float = 18
	Private GenerateNewPlatformsEnabled As Boolean = True
	Private BossDirection As Int
	Private BossSpeed As Int

	' افکت‌های جدید محیطی
	Private IsSnowing As Boolean = False
	Private IsSandStorm As Boolean = False
	Private IsVolcano As Boolean = False
	Private Snowflakes As List
	Private SandParticles As List
	Private VolcanoAshes As List
End Sub

Sub Globals
	Private Const PLAYER_SIZE As Int = 40dip
	Private Const PLATFORM_WIDTH As Int = 70dip
	Private Const PLATFORM_HEIGHT As Int = 20dip
	Private const  level As Int = File.ReadString(File.DirInternal,"level.txt")

	Private btnPauseStart As Button
	Private IsPaused1 As Boolean = False
	Private pauseBitmap As Bitmap
	Private playBitmap As Bitmap

	' افکت باران/برف/شن/آتشفشان
	Private RainParticles As List
	Private Const MAX_RAIN_PARTICLES As Int = 100
	Private Const RAIN_SPAWN_RATE As Int = 10
	Private RainIntensity As Float = 1.0
	Private IsRaining As Boolean = False
	Private RainTimer As Timer
	Private RainDuration As Int = 30000
	Private RainInterval As Int = 60000
	Private RainDrops As List
	Private Const MAX_RAIN_DROPS As Int = 150
	Private RainColor As Int = Colors.ARGB(150, 200, 200, 255)
	Private SnowColor As Int = Colors.ARGB(180, 255, 255, 255)
	Private SandColor As Int = Colors.ARGB(120, 255, 235, 120)
	Private AshColor As Int = Colors.ARGB(170, 90, 90, 90)
    
	' متغیرهای بازی
	Private Player As ImageView
	Private Platforms As List
	Private PlayerVelocityY As Float
	Private PlayerVelocityX As Float
	Private Score As Int
	Private lblScore As Label
	Private lblCountdown As Label
	Private lblHealth As Label
	Private pnlGame As Panel
	Private gameOverPanel As Panel
	Private Accelerometer As PhoneAccelerometer
	Private gameTimer As Timer
	Private SpringActive As Boolean
	Private ActiveParticles As List
	Private ParticleColors() As Int = Array As Int(Colors.RGB(89, 205, 50), Colors.RGB(96, 255, 48), Colors.RGB(11, 143, 7))
	Private sp As SoundPool
	Private soundJump, soundExplosion, soundSpring,soundCoin,soundEnemySpawn As Int
	Private Coins As List
	Private Const COIN_SIZE As Int = 20dip
	Private CoinCount As Int = 0
	Private lblCoins As Label
    
	Private enemysound As MediaPlayer
	Private PowerupType As String
    
	Private Bullets As List
	Private btnShoot As Button
	Private SpringTimers As List
	Private SpringPlatforms As Map
    
	Private Enemies As List
	Private Const ENEMY_SIZE As Int = 50dip
	Private Const ENEMY_HEALTH As Int = 1
	Private LastEnemySpawn As Long = 0
	Private NextEnemySpawnTime As Long
	Private EnemyBullets As List
	Private Const ENEMY_SHOOT_INTERVAL As Int = 5000
	Private LastEnemyShot As Long = 0

	Private Const MAX_ENEMIES As Int = 3
	Private Const SPIDER_SIZE As Int = 60dip
	Private Const WEB_WIDTH As Int = 5dip
	Private Const WEB_SPEED As Int = 3
	Private Spiders As List
	Private SpiderWebs As List
	Private EnemyWebBullets As List

	Private Const SPIDER_SPAWN_INTERVAL As Int = 8000
    
	Private mPanel As Panel
	Private Powerups As List
	Private Const POWERUP_SIZE As Int = 30dip
	Private SpringTimers As List
    
	Private BlinkTimer As Timer
	Private Const BLINK_INTERVAL As Int = 3000
	Private Const BLINK_DURATION As Int = 500
	Private IsBlinking As Boolean = False
	Private PlayerNormalBitmap As Bitmap
	Private PlayerBlinkBitmap As Bitmap
    
	Private StageCompleted As Boolean = False
	Private Const STAGE_TARGET_SCORE As Int = 1000
End Sub
' ادامه متغیرها و توابع...
' --- تنظیم افکت و سختی هر مرحله ---
Sub SetStageEffects(level As Int)
	IsRaining = False : IsSnowing = False : IsSandStorm = False : IsVolcano = False
	Select level
		Case 1, 4
			IsRaining = True
			RainIntensity = 1.0 + (level-1)*0.2
		Case 2
			IsSnowing = True
			RainIntensity = 1.3
		Case 3
			IsSandStorm = True
			RainIntensity = 1.5
		Case 5
			IsVolcano = True
			RainIntensity = 2.0
	End Select
	AdjustDifficultyByLevel(level)
End Sub

Sub AdjustDifficultyByLevel(level As Int)
	Select level
		Case 1
			MAX_ENEMIES = 3
			MaxParticles = 100
		Case 2
			MAX_ENEMIES = 4
			MaxParticles = 120
		Case 3
			MAX_ENEMIES = 5
			MaxParticles = 140
		Case 4
			MAX_ENEMIES = 6
			MaxParticles = 160
		Case 5
			MAX_ENEMIES = 8
			MaxParticles = 200
	End Select
End Sub

Sub InitializeEffectsForStage
	SetStageEffects(level)
	If IsSnowing Then
		Snowflakes.Initialize
	End If
	If IsSandStorm Then
		SandParticles.Initialize
	End If
	If IsVolcano Then
		VolcanoAshes.Initialize
	End If
End Sub

' افکت برف
Sub CreateSnowflake
	Dim flake As Panel
	flake.Initialize("")
	flake.Color = SnowColor
	Dim size As Int = Rnd(6dip, 12dip)
	Dim x As Int = Rnd(0, 100%x)
	Dim y As Int = -size
	pnlGame.AddView(flake, x, y, size, size)
	Snowflakes.Add(CreateMap("panel": flake, "speed": Rnd(5, 12)*RainIntensity, "wind": Rnd(-1, 1)))
End Sub

Sub UpdateSnow
	If Not(IsSnowing) Then Return
	If Snowflakes.Size < MAX_RAIN_DROPS And Rnd(0, 100) < (15 * RainIntensity) Then
		CreateSnowflake
	End If
	For i = Snowflakes.Size-1 To 0 Step -1
		Dim flakeData As Map = Snowflakes.Get(i)
		Dim flake As Panel = flakeData.Get("panel")
		If flake.IsInitialized Then
			flake.Left = flake.Left + flakeData.Get("wind")
			flake.Top = flake.Top + flakeData.Get("speed")
			If flake.Top > 100%y Or flake.Left < -30dip Or flake.Left > 100%x + 30dip Then
				SafeRemoveView(flake)
				Snowflakes.RemoveAt(i)
			End If
		Else
			Snowflakes.RemoveAt(i)
		End If
	Next
End Sub

' افکت شن
Sub CreateSandParticle
	Dim sand As Panel
	sand.Initialize("")
	sand.Color = SandColor
	Dim width As Int = Rnd(4dip, 12dip)
	Dim height As Int = Rnd(2dip, 5dip)
	Dim x As Int = Rnd(-30dip, 100%x)
	Dim y As Int = -height
	pnlGame.AddView(sand, x, y, width, height)
	SandParticles.Add(CreateMap("panel": sand, "speed": Rnd(12, 20)*RainIntensity, "wind": Rnd(2, 6)))
End Sub

Sub UpdateSandStorm
	If Not(IsSandStorm) Then Return
	If SandParticles.Size < MAX_RAIN_DROPS And Rnd(0, 100) < (18 * RainIntensity) Then
		CreateSandParticle
	End If
	For i = SandParticles.Size-1 To 0 Step -1
		Dim sandData As Map = SandParticles.Get(i)
		Dim sand As Panel = sandData.Get("panel")
		If sand.IsInitialized Then
			sand.Left = sand.Left + sandData.Get("wind")
			sand.Top = sand.Top + sandData.Get("speed")
			If sand.Top > 100%y Or sand.Left < -50dip Or sand.Left > 100%x + 50dip Then
				SafeRemoveView(sand)
				SandParticles.RemoveAt(i)
			End If
		Else
			SandParticles.RemoveAt(i)
		End If
	Next
End Sub

' افکت آتشفشان
Sub CreateVolcanoAsh
	Dim ash As Panel
	ash.Initialize("")
	Dim clr As Int = Colors.ARGB(Rnd(100, 200), Rnd(50, 120), Rnd(30, 30), Rnd(20, 20))
	ash.Color = clr
	Dim size As Int = Rnd(10dip, 20dip)
	Dim x As Int = Rnd(0, 100%x)
	Dim y As Int = -size
	pnlGame.AddView(ash, x, y, size, size)
	VolcanoAshes.Add(CreateMap("panel": ash, "speed": Rnd(16, 30)*RainIntensity, "wind": Rnd(-3, 3)))
End Sub

Sub UpdateVolcano
	If Not(IsVolcano) Then Return
	If VolcanoAshes.Size < MAX_RAIN_DROPS And Rnd(0, 100) < (20 * RainIntensity) Then
		CreateVolcanoAsh
	End If
	For i = VolcanoAshes.Size-1 To 0 Step -1
		Dim ashData As Map = VolcanoAshes.Get(i)
		Dim ash As Panel = ashData.Get("panel")
		If ash.IsInitialized Then
			ash.Left = ash.Left + ashData.Get("wind")
			ash.Top = ash.Top + ashData.Get("speed")
			If ash.Top > 100%y Or ash.Left < -50dip Or ash.Left > 100%x + 50dip Then
				SafeRemoveView(ash)
				VolcanoAshes.RemoveAt(i)
			End If
		Else
			VolcanoAshes.RemoveAt(i)
		End If
	Next
End Sub

' سکوهای تایم‌دار
Sub GenerateTimedPlatform(x As Int, y As Int)
	Dim platform As ImageView
	platform.Initialize("timedPlatform")
	platform.SetBackgroundImage(LoadBitmap(File.DirAssets,$"${"platform_time"}${level}.png"$))
	platform.Gravity = Gravity.FILL
	platform.Tag = "timed"
	pnlGame.AddView(platform, x, y, PLATFORM_WIDTH, PLATFORM_HEIGHT)
	Platforms.Add(platform)
	Dim t As Timer
	t.Initialize2("TimedPlatformExplode", Array As Object(platform), 3000)
	t.Tag = platform
	t.Enabled = True
End Sub

Sub TimedPlatformExplode(t As Timer)
	Dim platform As ImageView = t.Tag
	If platform.IsInitialized Then
		CreateExplosionEffect(platform)
		SafeRemoveView(platform)
		Platforms.RemoveAt(Platforms.IndexOf(platform))
		RemoveFromMovingPlatforms(platform)
	End If
	t.Enabled = False
End Sub

' ویرایش GenerateNewPlatforms برای اضافه کردن سکوهای متحرک/عمودی/تایم‌دار
Sub GenerateNewPlatforms
	Try
		If GenerateNewPlatformsEnabled = False Then Return
		Dim MIN_VERTICAL_GAP As Int = IIf(HelicopterMode, 15dip, 80dip)
		Dim highestTop As Int = FindHighestPlatformTop
		Dim triggerHeight As Int = IIf(HelicopterMode, 15%y, 40%y)
		If highestTop > triggerHeight Then highestTop = triggerHeight
		Dim verticalGap As Int = CalculatePlatformGap
		verticalGap = Max1(MIN_VERTICAL_GAP, verticalGap)
		Dim newY As Int = highestTop - verticalGap
		Dim platformCount As Int = IIf(HelicopterMode, Rnd(4, 6), Rnd(1, 3))
		For i = 0 To platformCount - 1
			If pnlGame.NumberOfViews > MAX_VIEWS - 10 Then Exit
			Dim platformX As Int
			Dim platformY As Int = newY - (i * verticalGap / 4)
			Dim validPosition As Boolean = False
			Dim attempts As Int = 0
			Dim maxAttempts As Int = 15
			Do While attempts < maxAttempts And validPosition = False
				platformX = Rnd(10dip, 90%x - PLATFORM_WIDTH)
				If IsPlatformOverlapping(platformX, platformY, PLATFORM_WIDTH, PLATFORM_HEIGHT) = False Then
					validPosition = True
				End If
				attempts = attempts + 1
			Loop
			If validPosition = False Then Continue

			Dim r As Int = Rnd(0, 100)
			If level >= 2 And r < 25 Then
				GenerateMovingPlatform(platformX, platformY)
				ElseIf level >= 3 And r >= 25 And r < 45 Then
				GenerateVerticalPlatform(platformX, platformY)
				ElseIf level >= 2 And r >= 45 And r < 60 Then
				GenerateTimedPlatform(platformX, platformY)
				ElseIf r >= 60 And r < 75 Then
				GenerateExplosivePlatform(platformX, platformY)
			Else
				GeneratePlatform(platformX, platformY, "normal")
			End If
			If Rnd(0, 100) < 30 Then
				GenerateSingleCoinOnPlatform(Platforms.Get(Platforms.Size-1))
			End If
			If Rnd(0, 100) < 3 Then
				GeneratePowerupOnRandomPlatform
			End If
		Next
	Catch
		Log("Error in GenerateNewPlatforms: " & LastException.Message)
	End Try
End Sub

' ویرایش تایمر بازی برای اجرای افکت‌های محیطی
Sub gameTimer_Tick
	If Not(gameStarted) Or IsPaused1 Then Return

	If Score >= STAGE_TARGET_SCORE Then
		StartBossFight
	End If

	If pnlGame.NumberOfViews > MAX_VIEWS Then
		Log("Warning: Too many views in pnlGame: " & pnlGame.NumberOfViews)
		For i = ActiveParticles.Size - 1 To MaxParticles Step -1
			Dim pData As Map = ActiveParticles.Get(i)
			SafeRemoveView(pData.Get("view"))
			ActiveParticles.RemoveAt(i)
		Next
	End If

	UpdateRain
	UpdateSnow
	UpdateSandStorm
	UpdateVolcano
	UpdateSpiderWebShots
	UpdatePlayerPosition
	UpdatePlatforms
	UpdateParticles
	UpdateCoins
	UpdateSpiders
	CheckPlatformCollisions
	CheckCoinCollisions
	UpdateMovingPlatforms
	UpdateScore
	CheckPowerupCollision
	UpdateBullets
	UpdateEnemies
	CheckEnemyCollisions
	UpdateEnemyBullets
	UpdatePowerups
	UpdateCoinAnimation
	TrySpawnEnemy

	If DateTime.Now - LastEnemyShot > ENEMY_SHOOT_INTERVAL Then
		For Each enemy As ImageView In Enemies
			If enemy.IsInitialized Then
				CreateEnemyBullet(enemy)
			End If
		Next
		LastEnemyShot = DateTime.Now
	End If
	pnlGame.Invalidate
    #If DEBUG
    Log($"Platforms: ${Platforms.Size}, Powerups: ${Powerups.Size}, Coins: ${Coins.Size}, Particles: ${ActiveParticles.Size}, Enemies: ${Enemies.Size}, Spiders: ${Spiders.Size}")
    #End If
End Sub

' شروع مرحله و افکت محیطی
Sub InitializeGame
	ResetGameVariables
	GameOver = False
	gameStarted = False
	Score = 0
	CoinCount = 0
	PlayerHealth = 3
	SpringActive = False
	GenerateNewPlatformsEnabled = True
	pnlGame.RemoveAllViews
	Platforms.Clear
	MovingPlatforms.Clear
	Coins.Clear
	ActiveParticles.Clear
	Enemies.Clear
	Spiders.Clear
	EnemyBullets.Clear
	EnemyWebBullets.Clear
	InitializeEffectsForStage
	pnlGame.Initialize("pnlGame")
	pnlGame.SetBackgroundImage(LoadBitmapResize(File.DirAssets, $"${"bg"}${level}.jpg"$, 100%x, 100%y, True))
	Activity.AddView(pnlGame, 0, 0, 100%x, 100%y)
	InitializePlayer
	Player.Top = 60%y
	Player.Left = 50%x - PLAYER_SIZE/2
	PlayerVelocityY = 0
	PlayerVelocityX = 0
	GenerateInitialPlatforms
	UpdateScore
	If gameOverPanel.IsInitialized Then
		gameOverPanel.Visible = False
	End If
	startTimer.Enabled = True
	gameTimer.Enabled = True
	Accelerometer.StartListening("Accelerometer")
	lblCountdown.Visible = True
	countdown = 5
	lblCountdown.Text =  countdown
	lblCountdown.Typeface = Typeface.LoadFromAssets("iranfnt.ttf")
	LastEnemySpawn = DateTime.Now
	NextEnemySpawnTime = Rnd(4000, 8000)
End Sub
' ... ادامه همانند سورس قبلی شما ...

' مثال فقط بخش آغاز توابع و ادامه بخش‌های مشترک:
Sub Activity_Create(FirstTime As Boolean)
	InitializeGame
End Sub

Sub Activity_Resume
	Enemies.Initialize
	EnemyBullets.Initialize
	EnemyWebBullets.Initialize
	Spiders.Initialize
	SpiderWebs.Initialize
	SpringTimers.Initialize
	Powerups.Initialize
	SpringTimers.Initialize
	SpringPlatforms.Initialize
	' افکت‌های جدید مراحل
	Snowflakes.Initialize
	SandParticles.Initialize
	VolcanoAshes.Initialize

	Platforms.Initialize
	MovingPlatforms.Initialize
	Coins.Initialize
	ActiveParticles.Initialize
	enemysound.Initialize2("enemysound")
	enemysound.Load(File.DirAssets, "enemy_sound.mp3")
	pnlGame.Initialize("pnlGame")
	pnlGame.SetBackgroundImage(LoadBitmapResize(File.DirAssets, $"${"bg"}${level}.jpg"$, 100%x, 100%y, True))
	Activity.AddView(pnlGame, 0, 0, 100%x, 100%y)
	InitializePlayer
	InitializeUI
	Player.Top = 60%y
	Player.Left = 50%x - PLAYER_SIZE/2
	PlayerVelocityY = 0
	PlayerVelocityX = 0
	PowerupTimer.Initialize("PowerupTimer", 10000)
	InitializeTimers
	GenerateInitialPlatforms
	StartCountdown
	Accelerometer.StartListening("Accelerometer")
	BlinkTimer.Initialize("BlinkTimer", BLINK_INTERVAL)
	BlinkTimer.Enabled = True
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	Accelerometer.StopListening
	gameTimer.Enabled = False
	startTimer.Enabled = False
	PowerupTimer.Enabled = False
	ClearRain
	If PowerupTimer.IsInitialized Then
		PowerupTimer.Enabled = False
	End If
	If BlinkTimer.IsInitialized Then
		BlinkTimer.Enabled = False
	End If
End Sub

' و همین‌طور همه توابع قبلی شما (مربوط به سکوها، دشمنان، ذرات، تایمرها...) بدون حذف، باقی بماند!

' انتهای فایل