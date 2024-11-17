import os
from flask import Flask, render_template, request, redirect, url_for
import subprocess

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/save_config', methods=['POST'])
def save_config():
    # Get form data
    project = request.form['project']
    firewall1_ip = request.form['firewall1_ip']
    firewall1_name = request.form['firewall1_name']
    firewall1_mgmt_ip = request.form['firewall1_mgmt_ip']
    firewall1_ha_ip = request.form['firewall1_ha_ip']
    temp_pass = request.form['temp_pass']
    soft_version = request.form['soft_version']
    master_key = request.form['master_key']
    auth_code = request.form['auth_code']
    cluster = request.form['cluster'] == 'True'
    vers_upgrade = request.form['vers_upgrade'] == '1'
    
    # Create project folder
    project_dir = os.path.join(os.getcwd(), project)
    os.makedirs(project_dir, exist_ok=True)
    
    # Create inventory.txt based on cluster choice
    inventory_path = os.path.join(project_dir, 'inventory.txt')
    with open(inventory_path, 'w') as f:
        f.write("[firewalls]\n")
        f.write("firewall1\n")
        if cluster:
            firewall2_ip = request.form['firewall2_ip']
            firewall2_name = request.form['firewall2_name']
            firewall2_mgmt_ip = request.form['firewall2_mgmt_ip']
            firewall2_ha_ip = request.form['firewall2_ha_ip']
            f.write("firewall2\n")
    
    # Create host_vars folder
    host_vars_path = os.path.join(project_dir, 'host_vars')
    os.makedirs(host_vars_path, exist_ok=True)
    
    # Create firewall1 and firewall2 YAML files
    firewall1_yml_path = os.path.join(host_vars_path, 'firewall1.yml')
    with open(firewall1_yml_path, 'w') as f1:
        f1.write(f"---\n")
        f1.write(f"ip_address: {firewall1_ip}\n")
        f1.write(f"username: protera\n")
        f1.write(f"password: {temp_pass}\n")
        f1.write(f"hostname: {firewall1_name}\n")
        f1.write(f"ha_peer_mgmt: {firewall1_mgmt_ip}\n")
        if firewall2_mgmt_ip.strip():
            f1.write(f"ha_peer_mgmt2: {firewall2_mgmt_ip}\n")
        if firewall1_ha_ip.strip():
            f1.write(f"ha_int_ip: {firewall1_ha_ip}\n")
        if soft_version.strip():
            f1.write(f"version1: {soft_version}\n")       
        f1.write(f"dev_priority: 90\n")
        f1.write(f"auth_code1: {auth_code}\n")
        f1.write(f"master_key1: {master_key}\n")
    
    if cluster:
        firewall2_yml_path = os.path.join(host_vars_path, 'firewall2.yml')
        with open(firewall2_yml_path, 'w') as f2:
            f2.write(f"---\n")
            f2.write(f"ip_address: {firewall2_ip}\n")
            f2.write(f"username: protera\n")
            f2.write(f"password: {temp_pass}\n")
            f2.write(f"hostname: {firewall2_name}\n")
            f2.write(f"ha_peer_mgmt: {firewall2_mgmt_ip}\n")
            f2.write(f"ha_peer_mgmt2: {firewall1_mgmt_ip}\n")
            f2.write(f"ha_int_ip: {firewall2_ha_ip}\n")
            f2.write(f"dev_priority: 100\n")
            f2.write(f"version1: {soft_version}\n")
            f2.write(f"auth_code1: {auth_code}\n")
            f2.write(f"master_key1: {master_key}\n")

    # Decide which Ansible playbook to run based on version upgrade
    playbook_url = "https://prot-ansible-ntwk.s3.us-east-1.amazonaws.com/palo-init-update.yml" if vers_upgrade else "https://prot-ansible-ntwk.s3.us-east-1.amazonaws.com/palo-init-wo-update.yml"
    
    # Download the Ansible playbook (optional - here we just use a URL directly)
    playbook_path = os.path.join(project_dir, 'playbook.yml')
    subprocess.run(['wget', playbook_url, '-O', playbook_path])

    # Run Ansible Playbook and capture the logs
    log_file_path = os.path.join(project_dir, 'logs.txt')
    ansible_cmd = f"ansible-playbook -i {inventory_path} {playbook_path}"
    with open(log_file_path, 'w') as log_file:
        subprocess.run(ansible_cmd, shell=True, stdout=log_file, stderr=log_file, cwd=project_dir)

    # Redirect user to logs page
    return redirect(url_for('view_logs', project=project))

@app.route('/logs/<project>', methods=['GET'])
def view_logs(project):
    # Path to the logs file
    log_file_path = os.path.join(os.getcwd(), project, 'logs.txt')

    # Read logs from the file
    if os.path.exists(log_file_path):
        with open(log_file_path, 'r') as log_file:
            logs = log_file.read()
    else:
        logs = "No logs available."

    # Render the logs page with auto-refresh
    return render_template('logs.html', logs=logs)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
