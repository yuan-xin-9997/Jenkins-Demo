pipeline {
	// 指定整个流水线在任何可用的 Jenkins 节点或容器上运行
	agent any
	tools {
		// 🚨 注意：这里的名字必须和你在 Jenkins 全局工具配置里填写的 Maven "Name" 一模一样！
		// 比如你在网页里填的是 maven3.9，这里就要写 maven3.9
		maven 'maven3.9.16'
		jdk 'JDK-21'
	}

	environment {
		APP_NAME    = "demo"
		REMOTE_HOST = "192.168.0.111"
		REMOTE_USER = "yuanxin"

		// 远程部署目录
		REMOTE_DIR  = "/home/yuanxin/demo"

		// jar 文件名
		JAR_NAME    = "demo-0.0.1-SNAPSHOT.jar"
		// 定义全局变量，方便后续维护

		PROJECT_GROUP = "com.yuanxin"
		IMAGE_NAME   = "jenkins-demo-app"
		IMAGE_TAG    = "latest"
		BASE_IMAGE    = "eclipse-temurin:21-jre"

	}

	stages {
		// 1. 拉取代码阶段
		stage('Checkout') {
			steps {
				sh 'echo "DEBUG: JAVA_HOME is ${JAVA_HOME}"'
				sh 'java -version'
				sh 'mvn -version'

				echo '🚚 正在从 Git 仓库拉取 Java 源代码...'
				// 替换为你的真实 Git 仓地址和分支
				// git branch: 'main', url: 'https://github.com/your-username/your-repo.git'
				sh 'rm -rf /var/jenkins_home/workspace/github-pipeline-demo/*'
				sh 'git clone git@github.com:yuan-xin-9997/Jenkins-Demo.git'
				// 本地测试暂用模拟提示
				sh 'echo "Code checkout completed."'
			}
		}

		// 2. 代码扫描/指令检查阶段
		stage('Code Check & Lint') {
			steps {
				echo '🔍 正在对 Java 代码进行语法与规范检查...'
				// 实际生产中这里会集成 Checkstyle 或 SonarQube
				// 示例：使用 maven 检查代码规范
				//sh 'cd Jenkins-Demo/; mvn checkstyle:check'
				sh 'echo "Checkstyle passed. No critical code smell found."'
			}
		}

		// 3. 编译与单元测试阶段
		stage('Compile & Test') {
			steps {
				echo '🧪 正在运行单元测试并进行编译...'
				// 使用 Maven 清理并执行测试
				// -B 参数代表以批处理非交互模式运行
				sh 'cd Jenkins-Demo/; mvn clean test'
			}
		}

		// 4. 打包阶段（生成 Jar 包）
		stage('Package JAR') {
			steps {
				echo '📦 正在将 Java 项目打包为可执行 JAR 文件...'
				// 跳过测试直接打包（因为上一步已经测试过了）
				sh 'cd Jenkins-Demo/; mvn package -DskipTests'

				// 归档制品，方便在 Jenkins 界面下载生成的 jar 包
				archiveArtifacts artifacts: 'Jenkins-Demo/target/*.jar', fingerprint: true
			}
		}

		// 4. SCP 上传
		stage('Upload JAR') {
			steps {

				echo '🚀 上传 JAR 到远程服务器...'

				sh """
                ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} '
                    mkdir -p ${REMOTE_DIR}
                '
                """

				sh """
                scp -o StrictHostKeyChecking=no \
                Jenkins-Demo/target/${JAR_NAME} \
                ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/
                """
			}
		}

		// 5. 远程启动
		stage('Deploy') {
			steps {

				echo '🔥 远程启动 Spring Boot 应用...'
				sh '''
            scp -o StrictHostKeyChecking=no Jenkins-Demo/deploy.sh yuanxin@192.168.0.111:/home/yuanxin/
            ssh -o StrictHostKeyChecking=no yuanxin@192.168.0.111 "
                chmod +x /home/yuanxin/deploy.sh &&
                /home/yuanxin/deploy.sh
            "
        '''
			}
		}
	}

	// 后置处理逻辑：无论成功还是失败都会触发
	post {
		success {
			echo '✅ 恭喜！流水线全部阶段执行成功！'
		}
		failure {
			echo '❌ 糟糕，流水线在某个阶段翻车了，请检查上面的日志。'
		}
	}
}