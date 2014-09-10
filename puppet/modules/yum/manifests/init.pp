class yum {
    file { "/etc/yum.repos.d/qnib.repo":
        owner   => root,
        group   => root,
        mode    => 644,
        source  => "puppet:///modules/yum/etc/yum.repos.d/qnib.repo",
    }
    file { "/etc/yum.repos.d/fedora-updates.repo":
        owner   => root,
        group   => root,
        mode    => 644,
        source  => "puppet:///modules/yum/etc/yum.repos.d/fedora-updates.repo",
    }
}
