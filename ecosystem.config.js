module.exports = {
  apps: [{
    name: 'teqst-backend',
    script: 'manage.py',
    cwd: '/opt/teqst/TEQST_Backend/TEQST',
    interpreter: '/opt/teqst/TEQST_Backend/venv/bin/python',
    args: 'runserver 127.0.0.1:8000',
    env: {
      DJANGO_SETTINGS_MODULE: 'TEQST.localsettings'
    },
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_file: './logs/combined.log',
    time: true
  }]
}
